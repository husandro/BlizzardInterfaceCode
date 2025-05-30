local helpTipSystem = "SpellBook Helptips";

SpellBookFrame_HelpPlates = {
	FramePos = { x = 5,	y = -22 },
};

SpellBookFrameTutorialsMixin = {};

function SpellBookFrameTutorialsMixin:OnLoad()
	self.HelpPlateButton:SetScript("OnClick", function() self:ToggleHelpPlates(); end);

	EventRegistry:RegisterCallback("PlayerSpellsFrame.OnManualMinimize",function()
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PLAYER_SPELLS_MINIMIZE, true);
		self:CheckShowHelpTips();
	end);
end

function SpellBookFrameTutorialsMixin:OnShow()
	self:CheckShowHelpTips();
end

function SpellBookFrameTutorialsMixin:OnHide()
	HelpTip:HideAllSystem(helpTipSystem);
	self:HideHelpPlates(false);
end

function SpellBookFrameTutorialsMixin:UpdateTutorialsForFrameSize()
	if self:AreHelpPlatesShowing() then
		-- Need to fully re-show help plates to get them adjusted to new sizes
		self:ShowHelpPlates();
	end
end

function SpellBookFrameTutorialsMixin:ShowHelpPlates()
	self:UpdateHelpPlates();
	HelpPlate.Show(SpellBookFrame_HelpPlates, self, self.HelpPlateButton);
end

function SpellBookFrameTutorialsMixin:HideHelpPlates(userToggled)
	if self:AreHelpPlatesShowing() then
		HelpPlate.Hide(userToggled);
	end
end

function SpellBookFrameTutorialsMixin:AreHelpPlatesShowing()
	return HelpPlate.IsShowingHelpInfo(SpellBookFrame_HelpPlates);
end

function SpellBookFrameTutorialsMixin:ToggleHelpPlates()
	if not self:AreHelpPlatesShowing() then
		self:ShowHelpPlates();
	else
		self:HideHelpPlates(true);
	end
end

function SpellBookFrameTutorialsMixin:UpdateHelpPlates()
	-- Scale multiplier required to convert positions relative to this frame's scale to be relative to HelpPlate's scale
	-- Particularly needed because PlayerSpells uses "checkFit" UIPanel setting which adjusts its scale
	local relativeScale = self:GetEffectiveScale() / HelpPlate.GetEffectiveScale();

	local width = self.isMinimized and self.minimizedWidth or self.maximizedWidth;
	SpellBookFrame_HelpPlates.FrameSize = { width = width * relativeScale, height = self:GetHeight() * relativeScale };

	-- SpellBookRevampTODO: Add more help plates as new UI is finished and desired new help text determined with design
	local maxTutorializedAreas = 2;
	for i = 1, maxTutorializedAreas do
		SpellBookFrame_HelpPlates[i] = nil;
	end
	local top = self:GetTop() * relativeScale;
	local left = self:GetLeft() * relativeScale;

	local pagedSpellsTop = (self.PagedSpellsFrame:GetTop() * relativeScale) - top + 10;
	local pagedSpellsLeft = (self.PagedSpellsFrame:GetLeft() * relativeScale) - left + 10;
	local pagedSpellsWidth = (self.PagedSpellsFrame:GetWidth() * relativeScale) - 30;
	local pagedSpellsHeight = (self.PagedSpellsFrame:GetHeight() * relativeScale) - 20;

	local pagedSpellsSection =
	{
		ButtonPos = { x = pagedSpellsLeft + (pagedSpellsWidth / 2), y = pagedSpellsTop - 50 },
		HighLightBox = { x = pagedSpellsLeft, y = pagedSpellsTop, width = pagedSpellsWidth, height = pagedSpellsHeight },
		ToolTipDir = "DOWN",
		ToolTipText = SPELLBOOK_HELP_1,
	}
	table.insert(SpellBookFrame_HelpPlates, pagedSpellsSection);

	if not self.isMinimized then
		local minimizeButtonSection =
		{
			ButtonPos = { x = pagedSpellsLeft + pagedSpellsWidth - 50, y = pagedSpellsTop + 70 },
			HighLightBox = { x = pagedSpellsLeft + pagedSpellsWidth - 105, y = pagedSpellsTop + 95, width = 100, height = 70 },
			ToolTipDir = "DOWN",
			ToolTipText = PLAYER_SPELLS_FRAME_MINIMIZE_TIP,
		}
		table.insert(SpellBookFrame_HelpPlates, minimizeButtonSection);
	end
end

function SpellBookFrameTutorialsMixin:CheckShowHelpTips()
	if not self:IsVisible() then
		return;
	end

	HelpTip:HideAllSystem(helpTipSystem);

	-- Helptips are parented to UIParent so they don't scale down with the spellbook frame

	local activeCategoryMixin = self:GetActiveCategoryMixin();
	local showNewlyBoostedHelptip = activeCategoryMixin
									and activeCategoryMixin:GetSpellBank() == Enum.SpellBookSpellBank.Player
									and IsCharacterNewlyBoosted()
									and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_BOOSTED_SPELL_BOOK);
	if showNewlyBoostedHelptip then
		-- If boosted, find the first locked spell and display a tip next to it
		local firstLockedSpellFrame = nil;
		for _, frame in self.PagedSpellsFrame:EnumerateFrames() do
			if frame.HasValidData and frame:HasValidData() and frame:GetItemType() == Enum.SpellBookItemType.FutureSpell then
				firstLockedSpellFrame = frame;
				break;
			end
		end

		if firstLockedSpellFrame then
			local helpTipInfo = {
				text = BOOSTED_CHAR_LOCKED_SPELL_TIP,
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				offsetX = -6,
				system = helpTipSystem,
				onAcknowledgeCallback = function() self:CheckShowHelpTips(); end,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_BOOSTED_SPELL_BOOK,
			};
			HelpTip:Show(UIParent, helpTipInfo, firstLockedSpellFrame);
			return;
		end
	end

	local showAssistedCombatRotationHelptip = AssistedCombatManager:HasActionSpell() and not GetCVarBitfield("closedInfoFramesAccountWide", LE_FRAME_TUTORIAL_ACCOUNT_ASSISTED_COMBAT_ROTATION_DRAG_SPELL);
	if showAssistedCombatRotationHelptip then
		local helpTipInfo = {
			text = ASSISTED_COMBAT_ROTATION_DRAG_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
			system = helpTipSystem,
			onAcknowledgeCallback = function() self:CheckShowHelpTips(); end,
			cvarBitfield = "closedInfoFramesAccountWide",
			bitfieldFlag = LE_FRAME_TUTORIAL_ACCOUNT_ASSISTED_COMBAT_ROTATION_DRAG_SPELL,
		};
		HelpTip:Show(UIParent, helpTipInfo, self.AssistedCombatRotationSpellFrame.Button);
		return;
	end
end
