local ExpansionLayoutInfo = {
	[LE_EXPANSION_DRAGONFLIGHT] = {
		textureDataTable = {
			["GlowLineBottom"] =  {
				atlas = "majorfaction-celebration-bottomglowline",
				useAtlasSize = true,
			},
			["RewardIconRing"] =  {
				atlas = "majorfaction-celebration-content-ring",
				useAtlasSize = false,
			},
			["ToastBG"] = {
				atlas = "majorfaction-celebration-toastBG",
				useAtlasSize = true,
				anchors = {
					["TOP"] = { x = 0, y = -77, relativePoint = "TOP" },
				},
			},
		},
	},
	[LE_EXPANSION_WAR_WITHIN] = {
		textureDataTable = {
			["GlowLineBottom"] =  {
				atlas = "majorfaction-celebration-thewarwithin-bottomglowline",
				useAtlasSize = true,
			},
			["RewardIconRing"] =  {
				atlas = "majorfaction-celebration-thewarwithin-content-ring",
				useAtlasSize = false,
			},
			["ToastBG"] = {
				atlas = "majorfaction-celebration-toastBG",
				useAtlasSize = true,
				anchors = {
					["TOP"] = { x = 0, y = -57, relativePoint = "TOP" },
				},
			},
		},
	},
};

MajorFactionsRenownToastMixin = {};

function MajorFactionsRenownToastMixin:OnLoad()
	self:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED");
end

function MajorFactionsRenownToastMixin:OnEvent(event, ...)
	if event == "MAJOR_FACTION_RENOWN_LEVEL_CHANGED" then
		local majorFactionID, newRenownLevel, oldRenownLevel = ...;
		local majorFactionData = C_MajorFactions.GetMajorFactionData(majorFactionID);
		if not majorFactionData or not majorFactionData.isUnlocked then
			return;
		end

		if newRenownLevel > oldRenownLevel and newRenownLevel > 1 then
			-- Wait a second for achievements to be granted, quests to be turned in, etc. (for reward player conditions)
			C_Timer.After(1, function() self:ShowRenownLevelUpToast(majorFactionData, newRenownLevel); end);
		end
	end
end

function MajorFactionsRenownToastMixin:OnHide()
	MajorFactionCelebrationBannerMixin.OnHide(self);

	TopBannerManager_BannerFinished();
end

function MajorFactionsRenownToastMixin:AddSwirlEffects(expansion) -- override
	local swirlEffects = MajorFactionUnlockToasts.GetSwirlEffectsByExpansion(expansion);
	if not swirlEffects then
		return;
	end

	for i, effect in ipairs(swirlEffects) do
		local effectDescription = { effectID = effect, soundEnabled = false, };
		self.IconSwirlModelScene:AddDynamicEffect(effectDescription, self);
	end
end

function MajorFactionsRenownToastMixin:ShowRenownLevelUpToast(majorFactionData, renownLevel)
	if majorFactionData then
		if MajorFactionRenownFrame then
			HideUIPanel(MajorFactionRenownFrame);
		end
		TopBannerManager_Show(self, {
			majorFactionID = majorFactionData.factionID,
			renownLevel = renownLevel,
			factionColor = majorFactionData.factionFontColor and majorFactionData.factionFontColor.color or HIGHLIGHT_FONT_COLOR,
			textureKit = majorFactionData.textureKit,
			celebrationSoundKit = majorFactionData.celebrationSoundKit,
			expansionID = majorFactionData.expansionID,
		});
	end
end

function MajorFactionsRenownToastMixin:SetupRewardVisuals(majorFactionID, renownLevel)
	local rewards = C_MajorFactions.GetRenownRewardsForLevel(majorFactionID, renownLevel);

	if #rewards > 0 then
		local primaryRewardInfo = rewards[1];
		local icon, name = RenownRewardUtil.GetUnformattedRenownRewardInfo(primaryRewardInfo, GenerateClosure(self.SetupRewardVisuals, self, majorFactionID, renownLevel))

		if icon then
			self.RewardIcon:SetTexture(icon);
			self.RewardIconMouseOver:Show();
			self.RewardIcon:Show();
			self.RewardIconRing:Show();
			self.RewardIcon:SetSize(52, 52);
		else
			self.RewardIconMouseOver:Hide();
			self.RewardIcon:Hide();
			self.RewardIcon:SetSize(1, 1);
			self.RewardIconRing:Hide();
		end

		local description = nil;
		for i, rewardInfo in ipairs(rewards) do
			if rewardInfo.toastDescription then
				if description then
					description = description .. "|n" .. rewardInfo.toastDescription;
				else
					description = rewardInfo.toastDescription;
				end
			end
		end

		self.RewardDescription:SetText(description or "");
	else
		self.RewardIconMouseOver:Hide();
		self.RewardIcon:Hide();
		self.RewardIcon:SetSize(1, 1);
		self.RewardIconRing:Hide();
		self.RewardDescription:SetText(nil);
	end
end

function MajorFactionsRenownToastMixin:PlayBanner(data)
	self.RenownLabel:SetFormattedText(MAJOR_FACTION_RENOWN_LEVEL_TOAST, data.renownLevel);
	self.RenownLabel:SetTextColor(data.factionColor:GetRGB());
	self:SetMajorFactionTextureKit(data.textureKit);
	self:SetMajorFactionSwirlEffects(data.expansionID);

	local expansionLayoutInfo = ExpansionLayoutInfo[data.expansionID] or ExpansionLayoutInfo[LE_EXPANSION_DRAGONFLIGHT];
	self:SetMajorFactionExpansionLayoutInfo(expansionLayoutInfo);

	self.ToastBG:SetAlpha(0);
	self.IconSwirlModelScene:SetAlpha(0);
	self.Icon:SetAlpha(0);
	self.RenownLabel:SetAlpha(0);
	self.RewardIcon:SetAlpha(0);
	self.RewardIconRing:SetAlpha(0);
	self.RewardDescription:SetAlpha(0);

	self:SetupRewardVisuals(data.majorFactionID, data.renownLevel);

	if data.celebrationSoundKit then
		PlaySound(data.celebrationSoundKit);
	end

	self.bannerData = data;

	self:SetAlpha(1);
	self:Show();
	self.ShowAnim:Stop();
	self.ShowAnim:Play();
end

function MajorFactionsRenownToastMixin:OnMouseEnter()
	GameTooltip:SetOwner(self.RewardIconMouseOver, "ANCHOR_NONE");
	GameTooltip:SetPoint("LEFT", self.RewardIconMouseOver, "RIGHT", 10, 0);
	self:RefreshTooltip();

	if self.ShowAnim.HoldAlpha:IsPlaying() then
		-- Holding already, just pause where we are
		self.ShowAnim.HoldAlpha:Pause();
	elseif self.ShowAnim.HoldAlpha:IsDone() then
		-- We're starting to fade out, reset alpha and hold
		self.ShowAnim.FadeAlpha:SetToAlpha(1);
		self.ShowAnim.FadeAlpha:Pause();
	else
		-- Still showing the fade-in, OnHoldAnimStarted will handle the transition
	end
end

function MajorFactionsRenownToastMixin:OnMouseLeave()
	self.ShowAnim.FadeAlpha:SetToAlpha(0);
	self.ShowAnim:Stop();
	local isReversed = false;
	self.ShowAnim:Play(isReversed, 1.0);

	GameTooltip_Hide(self);
end

function MajorFactionsRenownToastMixin:OnHoldAnimStarted()
	if GameTooltip:GetOwner() == self.RewardIconMouseOver then
		self.ShowAnim.HoldAlpha:Pause();
	end
end

function MajorFactionsRenownToastMixin:RefreshTooltip()
	if GameTooltip:GetOwner() ~= self.RewardIconMouseOver then
		return;
	end

	local onItemUpdateCallback = GenerateClosure(self.RefreshTooltip, self);
	local rewards = C_MajorFactions.GetRenownRewardsForLevel(self.bannerData.majorFactionID, self.bannerData.renownLevel);
	local addRewards = true;
	if self.isCapstone then
		GameTooltip_SetTitle(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_TITLE);
		GameTooltip_AddNormalLine(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_DESC);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddHighlightLine(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_DESC2);
	else
		if #rewards == 1 then
			local icon, name, description = RenownRewardUtil.GetRenownRewardInfo(rewards[1], onItemUpdateCallback);
			GameTooltip_SetTitle(GameTooltip, name);
			GameTooltip_AddNormalLine(GameTooltip, description);
			addRewards = false;
		else
			GameTooltip_SetTitle(GameTooltip, RENOWN_REWARD_MILESTONE_TOOLTIP_TITLE:format(self.bannerData.renownLevel));
		end
	end
	if addRewards then
		for i, rewardInfo in ipairs(rewards) do
			local icon, name, description = RenownRewardUtil.GetRenownRewardInfo(rewardInfo, onItemUpdateCallback);
			if name then
				GameTooltip_AddNormalLine(GameTooltip, RENOWN_REWARD_TOOLTIP_REWARD_LINE:format(name));
			end
		end
	end
	GameTooltip:Show();
end

function MajorFactionsRenownToastMixin:StopBanner()
	self.ShowAnim:Stop();
	self:Hide();
end

function MajorFactionsRenownToastMixin:OnAnimFinished()
	self:Hide();
end
