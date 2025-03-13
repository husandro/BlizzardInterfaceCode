COOLDOWN_VIEWER_ITEM_USABLE_COLOR = CreateColor(1.0, 1.0, 1.0, 1.0);
COOLDOWN_VIEWER_ITEM_NOT_ENOUGH_MANA_COLOR = CreateColor(0.5, 0.5, 1.0, 1.0);
COOLDOWN_VIEWER_ITEM_NOT_USABLE_COLOR = CreateColor(0.4, 0.4, 0.4, 1.0);
COOLDOWN_VIEWER_ITEM_NOT_IN_RANGE_COLOR = CreateColor(0.64, 0.15, 0.15, 1.0);

---------------------------------------------------------------------------------------------------
-- Some ways to generate fake data for edit mode if the character doesn't have enough spells to populate it.
local EditModeIconDataProvider = nil;

local function GetEditModeIcon(index)
	if not EditModeIconDataProvider then
		local spellIconsOnly = true;
		EditModeIconDataProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.Spellbook, spellIconsOnly);
	end

	return EditModeIconDataProvider:GetIconByIndex(index);
end

local function GetEditModeDuration(index)
	return index * 5;
end

local function GetEditModeElapsedTime(index)
	-- Just to give the different items within a category different values.
	if index % 2 == 1 then
		return index * 4;
	end

	return index * 2;
end

---------------------------------------------------------------------------------------------------
-- Base Mixin for all Cooldown Viewer items.
CooldownViewerItemMixin = {};

function CooldownViewerItemMixin:GetCooldownFrame()
	return self.Cooldown;
end

function CooldownViewerItemMixin:GetIconTexture()
	return self.Icon;
end

function CooldownViewerItemMixin:OnLoad()
	self:RefreshActive();

	local cooldownFrame = self:GetCooldownFrame();
	if cooldownFrame and self.cooldownFont then
		cooldownFrame:SetCountdownFont(self.cooldownFont);
	end
end

function CooldownViewerItemMixin:SetCooldownID(cooldownID)
	if self.cooldownID == cooldownID then
		return;
	end

	self.cooldownID = cooldownID;

	self:OnCooldownIDSet();
end

function CooldownViewerItemMixin:OnCooldownIDSet()
	self.cooldownInfo = C_CooldownViewer.GetCooldownViewerCooldownInfo(self.cooldownID);

	self:RegisterEvent("COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("UNIT_AURA");

	self:ClearEditModeData();

	self:RefreshData();
end

function CooldownViewerItemMixin:ClearCooldownID()
	if self.cooldownID == nil then
		return;
	end

	self.cooldownID = nil;
	
	self:OnCooldownIDCleared();
end

function CooldownViewerItemMixin:OnCooldownIDCleared()
	self.cooldownInfo = nil;

	self:UnregisterEvent("COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED");
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	self:UnregisterEvent("UNIT_AURA");

	self:RefreshData();
end

function CooldownViewerItemMixin:SetEditModeData(index)
	self.editModeIndex = index;
	self:RefreshData();
end

function CooldownViewerItemMixin:HasEditModeData()
	return self.editModeIndex ~= nil;
end

function CooldownViewerItemMixin:ClearEditModeData()
	if not self:HasEditModeData() then
		return;
	end

	self.editModeIndex = nil;
	self:RefreshData();
end

function CooldownViewerItemMixin:SetOverrideSpell(overrideSpellID)
	local cooldownInfo = self:GetCooldownInfo();
	if not cooldownInfo then
		return false;
	end

	if cooldownInfo.overrideSpellID == overrideSpellID then
		return false;
	end

	-- Capture the previous override for rare conditions involving spells that remove their
	-- override before the Update Cooldown Event is sent.
	if cooldownInfo.overrideSpellID and overrideSpellID == nil then
		cooldownInfo.previousOverrideSpellID = cooldownInfo.overrideSpellID;
	end

	cooldownInfo.overrideSpellID = overrideSpellID;

	return true;
end

function CooldownViewerItemMixin:SetLinkedSpell(linkedSpellID)
	local cooldownInfo = self:GetCooldownInfo();
	if not cooldownInfo then
		return false;
	end

	if cooldownInfo.linkedSpellID == linkedSpellID then
		return false;
	end

	cooldownInfo.linkedSpellID = linkedSpellID;

	return true;
end

function CooldownViewerItemMixin:GetLinkedSpell()
	local cooldownInfo = self:GetCooldownInfo();
	if not cooldownInfo then
		return nil;
	end

	return cooldownInfo.linkedSpellID;
end

function CooldownViewerItemMixin:UpdateLinkedSpell(spellID)
	local cooldownInfo = self:GetCooldownInfo();
	if not cooldownInfo then
		return false;
	end

	if not cooldownInfo.linkedSpellIDs then
		return false;
	end

	-- If the provided spellId matches the base spell then remove the linked spell's precedence.
	if cooldownInfo.linkedSpellID and spellID == cooldownInfo.spellID then
		return self:SetLinkedSpell(nil);
	end

	-- If the provided spellID is one of the item's linked spells, then give precedence to the linked spell.
	if tContains(cooldownInfo.linkedSpellIDs, spellID) then
		return self:SetLinkedSpell(spellID);
	end

	return false;
end

function CooldownViewerItemMixin:OnEvent(event, ...)
	if event == "COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED" then
		-- Any time an override is added or removed the item needs to be synchronously updated so
		-- it correctly responds to unique events happening later in the frame. To reduce redunant work
		-- the whole RefreshData isn't done until a unique event is received.
		local baseSpellID, overrideSpellID = ...;
		if baseSpellID == self:GetBaseSpellID() then
			self:SetOverrideSpell(overrideSpellID);
			self:RefreshData();
		end
	elseif event == "SPELL_UPDATE_COOLDOWN" then
		local spellID, baseSpellID, _category, startRecoveryCategory = ...;
		if self:NeedsCooldownUpdate(spellID, baseSpellID, startRecoveryCategory) then
			self:RefreshData();
		end
	elseif event == "UNIT_AURA" then
		local unit, unitAuraUpdateInfo = ...;
		if unitAuraUpdateInfo ~= nil then
			-- If the aura instance was removed or updated, then the item needs to be refreshed.
			if self.auraInstanceID ~= nil then
				if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil and tContains(unitAuraUpdateInfo.removedAuraInstanceIDs, self.auraInstanceID) then
					if self.auraSpellID == self:GetLinkedSpell() then
						self:SetLinkedSpell(nil);
					end

					self.auraInstanceID = nil;
					self.auraSpellID = nil;
					self:RefreshData();
				elseif unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil and tContains(unitAuraUpdateInfo.updatedAuraInstanceIDs, self.auraInstanceID) then
					self:RefreshData();
				elseif unitAuraUpdateInfo.addedAuras ~= nil then
					self:RefreshData();
				end
			-- If an aura was added and its spell matches the base, override, or a linked spell then the item needs to be refreshed.
			elseif unitAuraUpdateInfo.addedAuras ~= nil then
				for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
					if self:NeedsAddedAuraUpdate(aura.spellId) then
						self:RefreshData();
						break;
					end
				end
			end
		end
	end
end

function CooldownViewerItemMixin:GetCooldownID()
	return self.cooldownID;
end

function CooldownViewerItemMixin:GetCooldownInfo()
	return self.cooldownInfo;
end

-- Prefer calling GetSpellID in most cases. This function is provided for unique cases where the base spell is needed.
function CooldownViewerItemMixin:GetBaseSpellID()
	local cooldownInfo = self:GetCooldownInfo();
	if not cooldownInfo then
		return nil;
	end
	return cooldownInfo.spellID;
end

function CooldownViewerItemMixin:GetSpellID()
	if self.auraSpellID then
		return self.auraSpellID;
	end

	local cooldownInfo = self:GetCooldownInfo();
	if not cooldownInfo then
		return nil;
	end

	if cooldownInfo.linkedSpellID then
		return cooldownInfo.linkedSpellID;
	end

	if cooldownInfo.overrideSpellID then
		return cooldownInfo.overrideSpellID;
	end

	return cooldownInfo.spellID;
end

function CooldownViewerItemMixin:GetSpellCooldownInfo()
	local spellID = self:GetSpellID();
	if not spellID then
		return nil;
	end
	return C_Spell.GetSpellCooldown(spellID);
end

function CooldownViewerItemMixin:GetSpellChargeInfo()
	local spellID = self:GetSpellID();
	if not spellID then
		return nil;
	end
	return C_Spell.GetSpellCharges(spellID);
end

function CooldownViewerItemMixin:GetSpellTexture()
	-- Intentionally always use the base spell when calling C_Spell.GetSpellTexture. Its internal logic will handle the override if needed.
	local spellID = self:GetBaseSpellID();
	if not spellID then
		if self:HasEditModeData() then
			return GetEditModeIcon(self.editModeIndex);
		end

		return nil;
	end
	return C_Spell.GetSpellTexture(spellID);
end

function CooldownViewerItemMixin:GetAuraData()
	local spellID = self:GetSpellID();
	if not spellID then
		return nil;
	end
	return C_UnitAuras.GetPlayerAuraBySpellID(spellID);
end

function CooldownViewerItemMixin:UseAuraForCooldown()
	local cooldownInfo = self:GetCooldownInfo();
	if not cooldownInfo then
		return true;
	end

	if cooldownInfo.flags == nil then
		return true;
	end

	return FlagsUtil.IsSet(cooldownInfo.flags, Enum.CooldownSetSpellFlags.HideAura) == false;
end

function CooldownViewerItemMixin:RefreshData()
	assertsafe(false, "RefreshData must be overridden by a derived mixin.");
end

function CooldownViewerItemMixin:RefreshActive()
	self:SetIsActive(self:ShouldBeActive());
end

function CooldownViewerItemMixin:RefreshSpellTexture()
	local spellTexture = self:GetSpellTexture();
	self:GetIconTexture():SetTexture(spellTexture);
end

function CooldownViewerItemMixin:RefreshAuraInstance()
	local auraData = self:GetAuraData();
	if auraData then
		self.auraInstanceID = auraData.auraInstanceID;
		self.auraSpellID = auraData.spellId;
	else
		self.auraInstanceID = nil;
		self.auraSpellID = nil;
	end
end

function CooldownViewerItemMixin:SetTimerShown(shownSetting)
	local cooldownFrame = self:GetCooldownFrame();
	if cooldownFrame then
		cooldownFrame:SetHideCountdownNumbers(not shownSetting);
	end
end

function CooldownViewerItemMixin:IsTimerShown()
	local cooldownFrame = self:GetCooldownFrame();
	if cooldownFrame then
		return not cooldownFrame:GetHideCountdownNumbers();
	end
	return false;
end

function CooldownViewerItemMixin:ShouldBeActive()
	return self.cooldownID ~= nil;
end

function CooldownViewerItemMixin:OnActiveStateChanged()
	if self.activeStateChangedEvent then
		EventRegistry:TriggerEvent(self.activeStateChangedEvent, self);
	end
end

function CooldownViewerItemMixin:SetIsActive(active)
	if active == self.isActive then
		return;
	end

	self.isActive = active;

	self:OnActiveStateChanged();
end

function CooldownViewerItemMixin:IsActive()
	return self.isActive;
end

function CooldownViewerItemMixin:IsActivationOverlayActive()
	return self.SpellActivationAlert and self.SpellActivationAlert:IsShown();
end

function CooldownViewerItemMixin:NeedsCooldownUpdate(spellID, baseSpellID, startRecoveryCategory)
	-- A nill spellID indicates all cooldowns should be updated.
	if spellID == nil then
		return true;
	end

	if self:UpdateLinkedSpell(spellID) then
		return true;
	end

	if startRecoveryCategory == Constants.SpellCooldownConsts.GLOBAL_RECOVERY_CATEGORY then
		return true;
	end

	local itemBaseSpellID = self:GetBaseSpellID();

	if spellID == itemBaseSpellID then
		return true;
	end

	-- Depending on the order of overrides being applied and removed, the item may already have a
	-- different override spell than the spell being updated. But if the base spell is the same, the
	-- item should still respond to the event.
	if baseSpellID == itemBaseSpellID then
		return true;
	end

	if spellID == self:GetSpellID() then
		return true;
	end

	-- In rare cases, some spells remove their override before the Update Cooldown Event is sent. 
	-- When this happens the event doesn't correctly reference the base spell, so this logic
	-- compensates for that to ensure the event causes a refresh.
	if spellID == self.cooldownInfo.previousOverrideSpellID then
		return true;
	end

	return false;
end

function CooldownViewerItemMixin:NeedsAddedAuraUpdate(spellID)
	if self:UpdateLinkedSpell(spellID) then
		return true;
	end

	if spellID == self:GetSpellID() then
		return true;
	end

	return false;
end

---------------------------------------------------------------------------------------------------
-- Base Mixin for Essential and Utility cooldown items.
CooldownViewerCooldownItemMixin = CreateFromMixins(CooldownViewerItemMixin);

function CooldownViewerCooldownItemMixin:GetChargeCountFrame()
	return self.ChargeCount;
end

function CooldownViewerCooldownItemMixin:GetCooldownFlashFrame()
	return self.CooldownFlash;
end

function CooldownViewerCooldownItemMixin:GetOutOfRangeTexture()
	return self.OutOfRange;
end

function CooldownViewerCooldownItemMixin:OnLoad()
	CooldownViewerItemMixin.OnLoad(self);

	self:GetCooldownFrame():SetScript("OnCooldownDone", GenerateClosure(self.OnCooldownDone, self));
end

function CooldownViewerCooldownItemMixin:OnCooldownIDSet()
	CooldownViewerItemMixin.OnCooldownIDSet(self);

	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
	self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");
	self:RegisterEvent("SPELL_UPDATE_USES");
	self:RegisterEvent("SPELL_UPDATE_USABLE");

	self:RefreshOverlayGlow();

	local baseSpellID = self:GetBaseSpellID();
	self.needsRangeCheck = baseSpellID and C_Spell.SpellHasRange(baseSpellID);
	if self.needsRangeCheck == true then
		self.rangeCheckSpellID = baseSpellID;
		C_Spell.EnableSpellRangeCheck(self.rangeCheckSpellID, true);
		self.spellOutOfRange = C_Spell.IsSpellInRange(self.rangeCheckSpellID) == false;
		self:RegisterEvent("SPELL_RANGE_CHECK_UPDATE");
		self:RefreshIconColor();
	end
end

function CooldownViewerCooldownItemMixin:OnCooldownIDCleared()
	CooldownViewerItemMixin.OnCooldownIDCleared(self);

	self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
	self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");
	self:UnregisterEvent("SPELL_UPDATE_USES");
	self:UnregisterEvent("SPELL_UPDATE_USABLE");

	ActionButton_HideOverlayGlow(self);

	if self.needsRangeCheck == true then
		C_Spell.EnableSpellRangeCheck(self.rangeCheckSpellID, false);
		self:UnregisterEvent("SPELL_RANGE_CHECK_UPDATE");
		self.rangeCheckSpellID = nil;
		self.spellOutOfRange = nil;
	end
end

function CooldownViewerCooldownItemMixin:OnCooldownDone()
	self:RefreshIconDesaturation();
end

function CooldownViewerCooldownItemMixin:OnEvent(event, ...)
	CooldownViewerItemMixin.OnEvent(self, event, ...);

	if event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" then
		local spellID = ...;
		if self:NeedSpellActivationUpdate(spellID) then
			ActionButton_ShowOverlayGlow(self);
		end
	elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" then
		local spellID = ...;
		if self:NeedSpellActivationUpdate(spellID) then
			ActionButton_HideOverlayGlow(self);
		end
	elseif event == "SPELL_UPDATE_USES" then
		local spellID, baseSpellID = ...;
		if self:NeedSpellUseUpdate(spellID, baseSpellID) then
			self:RefreshSpellChargeInfo();
		end
	elseif event == "SPELL_UPDATE_USABLE" then
		self:RefreshIconColor();
	elseif event == "SPELL_RANGE_CHECK_UPDATE" then
		local spellID, inRange, checksRange = ...;
		if self:NeedsSpellRangeUpdate(spellID) then
			self.spellOutOfRange = checksRange == true and inRange == false;
			self:RefreshIconColor();
		end
	end
end

function CooldownViewerCooldownItemMixin:NeedSpellActivationUpdate(spellID)
	if spellID == self:GetSpellID() then
		return true;
	end

	return false;
end

function CooldownViewerCooldownItemMixin:NeedSpellUseUpdate(spellID, baseSpellID)
	if spellID == self:GetSpellID() then
		return true;
	end

	if baseSpellID and baseSpellID == self:GetBaseSpellID() then
		return true;
	end

	return false;
end

function CooldownViewerCooldownItemMixin:NeedsSpellRangeUpdate(spellID)
	if spellID == self.rangeCheckSpellID then
		return true;
	end

	return false;
end

function CooldownViewerCooldownItemMixin:CacheCooldownValues()
	-- If the spell results in a self buff, give those values precedence over the spell's cooldown until the buff is gone.
	if self:UseAuraForCooldown() == true then
		local auraData = self:GetAuraData();
		if auraData then
			self.cooldownEnabled = 1;
			self.cooldownStartTime = auraData.expirationTime - auraData.duration;
			self.cooldownDuration = auraData.duration;
			self.cooldownModRate = auraData.timeMod;
			self.cooldownSwipeColor = CreateColor(1, 0.95, 0.57, 0.7);
			self.cooldownDesaturated = false;
			self.cooldownShowDrawEdge = false;
			self.cooldownShowSwipe = true;
			self.cooldownUseAuraDisplayTime = true;
			self.cooldownPlayFlash = false;
			self.cooldownPaused = false;
			return;
		end
	end

	local spellChargeInfo = self:GetSpellChargeInfo();
	local displayChargeCooldown = spellChargeInfo
		and spellChargeInfo.cooldownStartTime
		and spellChargeInfo.cooldownStartTime > 0
		and spellChargeInfo.currentCharges
		and spellChargeInfo.currentCharges > 0;

	-- If the spell has multiple charges, give those values precedence over the spell's cooldown until the charges are spent.
	if displayChargeCooldown then
		self.cooldownEnabled = 1;
		self.cooldownStartTime = spellChargeInfo.cooldownStartTime;
		self.cooldownDuration = spellChargeInfo.cooldownDuration;
		self.cooldownModRate = spellChargeInfo.chargeModRate;
		self.cooldownSwipeColor = CreateColor(0, 0, 0, 0.7);
		self.cooldownDesaturated = false;
		self.cooldownShowDrawEdge = true;
		self.cooldownShowSwipe = false;
		self.cooldownUseAuraDisplayTime = false;
		self.cooldownPlayFlash = true;
		self.cooldownPaused = false;
		return;
	end

	local spellCooldownInfo = self:GetSpellCooldownInfo();
	if spellCooldownInfo then
		self.cooldownEnabled = spellCooldownInfo.isEnabled;
		self.cooldownStartTime = spellCooldownInfo.startTime;
		self.cooldownDuration = spellCooldownInfo.duration;
		self.cooldownModRate = spellCooldownInfo.modRate;
		self.cooldownSwipeColor = CreateColor(0, 0, 0, 0.7);
		self.cooldownShowDrawEdge = false;
		self.cooldownShowSwipe = true;
		self.cooldownUseAuraDisplayTime = false;
		self.cooldownPaused = false;

		if spellCooldownInfo.activeCategory == Constants.SpellCooldownConsts.GLOBAL_RECOVERY_CATEGORY then
			self.cooldownDesaturated = false;
			self.cooldownPlayFlash = false;
		else
			self.cooldownDesaturated = true;
			self.cooldownPlayFlash = true;
		end

		return;
	end

	if self:HasEditModeData() then
		self.cooldownEnabled = 1;
		self.cooldownStartTime = GetTime() - GetEditModeElapsedTime(self.editModeIndex);
		self.cooldownDuration = GetEditModeDuration(self.editModeIndex);
		self.cooldownModRate = 1;
		self.cooldownSwipeColor = CreateColor(0, 0, 0, 0.7);
		self.cooldownDesaturated = false;
		self.cooldownShowDrawEdge = false;
		self.cooldownShowSwipe = true;
		self.cooldownUseAuraDisplayTime = false;
		self.cooldownPlayFlash = false;
		self.cooldownPaused = true;
		return;
	end

	self.cooldownEnabled = 0;
	self.cooldownStartTime = 0;
	self.cooldownDuration = 0;
	self.cooldownModRate = 1;
	self.cooldownSwipeColor = CreateColor(0, 0, 0, 0);
	self.cooldownDesaturated = false;
	self.cooldownShowDrawEdge = false;
	self.cooldownShowSwipe = false;
	self.cooldownUseAuraDisplayTime = false;
	self.cooldownPlayFlash = false;
	self.cooldownPaused = false;
end

function CooldownViewerCooldownItemMixin:CacheChargeValues()
	-- Give precedence to spells set up with explicit charge info that have more than one max charge.
	local spellChargeInfo = self:GetSpellChargeInfo();
	if spellChargeInfo and spellChargeInfo.maxCharges > 1 then
		self.cooldownChargesShown = true;
		self.cooldownChargesCount = spellChargeInfo.currentCharges;
		return;
	end

	-- Some spells are set up to show 'cast count' (also called 'use count') which can have different meanings base on the context of the spell.
	local spellID = self:GetSpellID();
	if spellID then
		self.cooldownChargesCount = C_Spell.GetSpellCastCount(spellID);
		self.cooldownChargesShown = self.cooldownChargesCount > 0;
		return;
	end

	self.cooldownChargesShown = false;
end

function CooldownViewerCooldownItemMixin:IsExpired()
	if self.cooldownStartTime == 0 then
		return true;
	end

	return self.cooldownStartTime + self.cooldownDuration <= GetTime();
end

function CooldownViewerCooldownItemMixin:RefreshSpellCooldownInfo()
	self:CacheCooldownValues();

	local cooldownFrame = self:GetCooldownFrame();
	local isExpired = self:IsExpired();

	if isExpired then
		CooldownFrame_Clear(cooldownFrame);
		cooldownFrame:SetDrawEdge(false);
	else
		cooldownFrame:SetSwipeColor(self.cooldownSwipeColor.r, self.cooldownSwipeColor.g, self.cooldownSwipeColor.b, self.cooldownSwipeColor.a);
		cooldownFrame:SetDrawSwipe(self.cooldownShowSwipe);
		cooldownFrame:SetUseAuraDisplayTime(self.cooldownUseAuraDisplayTime);
		CooldownFrame_Set(cooldownFrame, self.cooldownStartTime, self.cooldownDuration, self.cooldownEnabled, self.cooldownShowDrawEdge, self.cooldownModRate);
	end

	if self.cooldownPaused then
		cooldownFrame:Pause();
	else
		cooldownFrame:Resume();
	end

	local cooldownFlashFrame = self:GetCooldownFlashFrame();
	local playFlash = self.cooldownPlayFlash and not isExpired;

	if playFlash then
		local startDelay = self.cooldownStartTime + self.cooldownDuration - GetTime() - 0.75;

		cooldownFlashFrame:Show();
		cooldownFlashFrame.FlashAnim:Stop();
		cooldownFlashFrame.FlashAnim.ShowAnim:SetStartDelay(startDelay);
		cooldownFlashFrame.FlashAnim.PlayAnim:SetStartDelay(startDelay);
		cooldownFlashFrame.FlashAnim:Play();
	else
		cooldownFlashFrame:Hide();
		cooldownFlashFrame.FlashAnim:Stop();
	end
end

function CooldownViewerCooldownItemMixin:RefreshSpellChargeInfo()
	self:CacheChargeValues();

	local chargeCountFrame = self:GetChargeCountFrame();

	chargeCountFrame:SetShown(self.cooldownChargesShown);

	if self.cooldownChargesShown then
		chargeCountFrame.Current:SetText(self.cooldownChargesCount);
	end
end

function CooldownViewerCooldownItemMixin:RefreshIconDesaturation()
	local iconTexture = self:GetIconTexture();
	local desaturated = self.cooldownDesaturated and not self:IsExpired();

	iconTexture:SetDesaturated(desaturated);
end

function CooldownViewerCooldownItemMixin:RefreshIconColor()
	local spellID = self:GetSpellID();
	if not spellID then
		return;
	end

	local iconTexture = self:GetIconTexture();
	local outOfRangeTexture = self:GetOutOfRangeTexture();

	local isUsable, notEnoughMana = C_Spell.IsSpellUsable(spellID);

	if self.spellOutOfRange == true then
		iconTexture:SetVertexColor(COOLDOWN_VIEWER_ITEM_NOT_IN_RANGE_COLOR:GetRGBA());
	elseif isUsable then
		iconTexture:SetVertexColor(COOLDOWN_VIEWER_ITEM_USABLE_COLOR:GetRGBA());
	elseif notEnoughMana then
		iconTexture:SetVertexColor(COOLDOWN_VIEWER_ITEM_NOT_ENOUGH_MANA_COLOR:GetRGBA());
	else
		iconTexture:SetVertexColor(COOLDOWN_VIEWER_ITEM_NOT_USABLE_COLOR:GetRGBA());
	end

	outOfRangeTexture:SetShown(self.spellOutOfRange == true);
end

function CooldownViewerCooldownItemMixin:RefreshOverlayGlow()
	local spellID = self:GetSpellID();
	local isSpellOverlayed = spellID and IsSpellOverlayed(spellID) or false;
	if isSpellOverlayed then
		ActionButton_ShowOverlayGlow(self);
	else
		ActionButton_HideOverlayGlow(self);
	end
end

function CooldownViewerCooldownItemMixin:RefreshData()
	self:RefreshAuraInstance();
	self:RefreshSpellCooldownInfo();
	self:RefreshSpellChargeInfo();
	self:RefreshSpellTexture();
	self:RefreshIconDesaturation();
	self:RefreshIconColor();
	self:RefreshOverlayGlow();
	self:RefreshActive();
end

---------------------------------------------------------------------------------------------------
CooldownViewerEssentialItemMixin = CreateFromMixins(CooldownViewerCooldownItemMixin);

---------------------------------------------------------------------------------------------------
CooldownViewerUtilityItemMixin = CreateFromMixins(CooldownViewerCooldownItemMixin);

---------------------------------------------------------------------------------------------------
-- Base Mixin for BuffIcon and BuffBar cooldown items.
CooldownViewerBuffItemMixin = CreateFromMixins(CooldownViewerItemMixin);

function CooldownViewerBuffItemMixin:OnCooldownIDSet()
	CooldownViewerItemMixin.OnCooldownIDSet(self);

	self:RegisterEvent("PLAYER_TOTEM_UPDATE");
end

function CooldownViewerBuffItemMixin:OnCooldownIDCleared()
	-- Totem data is intentionally cleared before calling the base function so the call to RefreshData operates correctly.
	self:ClearTotemData();

	CooldownViewerItemMixin.OnCooldownIDCleared(self);

	self:UnregisterEvent("PLAYER_TOTEM_UPDATE");
end

function CooldownViewerBuffItemMixin:OnEvent(event, ...)
	CooldownViewerItemMixin.OnEvent(self, event, ...);

	if event == "PLAYER_TOTEM_UPDATE" then
		local slot = ...;
		local _haveTotem, name, startTime, duration, _icon, modRate, spellID = GetTotemInfo(slot);
		if self:NeedsTotemUpdate(slot, spellID) then
			self.totemData = {
				slot = slot,
				expirationTime = startTime + duration,
				duration = duration,
				name = name,
				modRate = modRate;
			};
			self:RefreshData();
		end
	end
end

function CooldownViewerBuffItemMixin:NeedsTotemUpdate(slot, spellID)
	if self:UpdateLinkedSpell(spellID) then
		return true;
	end

	if spellID == self:GetSpellID() then
		return true;
	end

	-- If a totem is destroyed the totem's spellID may already be set to 0, in which case
	-- it's necessary to use the slot to determine if the update is needed.
	if spellID == 0 and self.totemData and self.totemData.slot == slot then
		return true;
	end

	return false;
end

function CooldownViewerBuffItemMixin:GetTotemData()
	return self.totemData;
end

function CooldownViewerBuffItemMixin:ClearTotemData()
	self.totemData = nil;
end

function CooldownViewerBuffItemMixin:ShouldBeActive()
	if not CooldownViewerItemMixin.ShouldBeActive(self) then
		return false;
	end

	local totemData = self:GetTotemData();
	if totemData then
		return totemData.expirationTime > GetTime();
	end

	local auraData = self:GetAuraData();
	if auraData then
		-- Auras with an expirationTime of 0 are infinite and considered active until they are removed.
		if auraData.expirationTime == 0 then
			return true;
		end

		return auraData.expirationTime > GetTime();
	end

	return false;
end

function CooldownViewerBuffItemMixin:OnActiveStateChanged()
	CooldownViewerItemMixin.OnActiveStateChanged(self);

	local active = self:IsActive();
	if not active then
		self:ClearTotemData();
	end
end

function CooldownViewerBuffItemMixin:GetCooldownValues()
	local paused = false;

	local totemData = self:GetTotemData();
	if totemData then
		return totemData.expirationTime, totemData.duration, totemData.modRate, paused;
	end

	local auraData = self:GetAuraData();
	if auraData then
		return auraData.expirationTime, auraData.duration, auraData.timeMod, paused;
	end

	local modRate = 1;
	local expirationTime = 0;
	local duration = 0;

	if self:HasEditModeData() then
		duration = GetEditModeDuration(self.editModeIndex);
		expirationTime = GetTime() - GetEditModeElapsedTime(self.editModeIndex) + duration;
		paused = true;
		return expirationTime, duration, modRate, paused;
	end

	return expirationTime, duration, modRate, paused;
end

function CooldownViewerBuffItemMixin:GetApplicationsText()
	local auraData = self:GetAuraData();
	if auraData and auraData.applications and auraData.applications > 1 then
		return auraData.applications;
	end

	return "";
end

---------------------------------------------------------------------------------------------------
CooldownViewerBuffIconItemMixin = CreateFromMixins(CooldownViewerBuffItemMixin);

function CooldownViewerBuffIconItemMixin:GetApplicationsFrame()
	return self.Applications;
end

function CooldownViewerBuffIconItemMixin:GetApplicationsFontString()
	local applicationsFrame = self:GetApplicationsFrame();
	return applicationsFrame.Applications;
end

function CooldownViewerBuffIconItemMixin:OnLoad()
	CooldownViewerBuffItemMixin.OnLoad(self);

	local cooldownFrame = self:GetCooldownFrame();
	cooldownFrame:SetUseAuraDisplayTime(true);

	self:GetCooldownFrame():SetScript("OnCooldownDone", GenerateClosure(self.OnCooldownDone, self));
end

function CooldownViewerBuffIconItemMixin:OnEvent(event, ...)
	CooldownViewerBuffItemMixin.OnEvent(self, event, ...);
end

function CooldownViewerBuffIconItemMixin:OnCooldownDone()
	self:RefreshActive();
end

function CooldownViewerBuffIconItemMixin:RefreshCooldownInfo()
	local cooldownFrame = self:GetCooldownFrame();

	local expirationTime, duration, timeMod, paused = self:GetCooldownValues();
	local currentTime = expirationTime - GetTime();

	if currentTime > 0 then
		local startTime = expirationTime - duration;
		local isEnabled = 1;
		local forceShowDrawEdge = false;
		CooldownFrame_Set(cooldownFrame, startTime, duration, isEnabled, forceShowDrawEdge, timeMod);
	else
		CooldownFrame_Clear(cooldownFrame);
	end

	if paused then
		cooldownFrame:Pause();
	else
		cooldownFrame:Resume();
	end
end

function CooldownViewerBuffIconItemMixin:RefreshApplications()
	local applicationsText = self:GetApplicationsText();

	local applicationsFontString = self:GetApplicationsFontString();
	applicationsFontString:SetText(applicationsText);
end

function CooldownViewerBuffIconItemMixin:RefreshData()
	self:RefreshAuraInstance();
	self:RefreshCooldownInfo();
	self:RefreshSpellTexture();
	self:RefreshApplications();
	self:RefreshActive();
end

---------------------------------------------------------------------------------------------------
CooldownViewerBuffBarItemMixin = CreateFromMixins(CooldownViewerBuffItemMixin);

function CooldownViewerBuffBarItemMixin:GetIconFrame()
	return self.Icon;
end

function CooldownViewerBuffBarItemMixin:GetIconTexture()
	local iconFrame = self:GetIconFrame();
	return iconFrame.Icon;
end

function CooldownViewerBuffBarItemMixin:GetBarFrame()
	return self.Bar;
end

function CooldownViewerBuffBarItemMixin:GetPipTexture()
	local barFrame = self:GetBarFrame();
	return barFrame.Pip;
end

function CooldownViewerBuffBarItemMixin:GetNameFontString()
	return self.Bar.Name;
end

function CooldownViewerBuffBarItemMixin:GetDurationFontString()
	return self.Bar.Duration;
end

function CooldownViewerBuffBarItemMixin:GetApplicationsFontString()
	local iconFrame = self:GetIconFrame();
	return iconFrame.Applications;
end

function CooldownViewerBuffBarItemMixin:OnLoad()
	CooldownViewerBuffItemMixin.OnLoad(self);

	local pipTexture = self:GetPipTexture();
	local barFrame = self:GetBarFrame();
	pipTexture:ClearAllPoints();
	pipTexture:SetPoint("CENTER", barFrame:GetStatusBarTexture(), "RIGHT", 0, 0);
end

function CooldownViewerBuffBarItemMixin:OnEvent(event, ...)
	CooldownViewerBuffItemMixin.OnEvent(self, event, ...);
end

function CooldownViewerBuffBarItemMixin:OnUpdate()
	self:RefreshCooldownInfo();
	self:RefreshActive();
end

function CooldownViewerBuffBarItemMixin:SetBarContent(barContent)
	local iconFrame = self:GetIconFrame();
	local nameFontString = self:GetNameFontString();
	local point, relativeTo, relativePoint, offsetX, offsetY = "LEFT", iconFrame, "RIGHT", 0, 0;

	if barContent == Enum.CooldownViewerBarContent.IconAndName then
		iconFrame:Show();
		nameFontString:Show();
	elseif barContent == Enum.CooldownViewerBarContent.IconOnly then
		iconFrame:Show();
		nameFontString:Hide();
	elseif barContent == Enum.CooldownViewerBarContent.NameOnly then
		iconFrame:Hide();
		nameFontString:Show();
		relativeTo = self;
		relativePoint = "LEFT";
	else
		assertsafe(false, "Unknown value for bar content: %d", barContent);
	end

	self:GetBarFrame():SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);
end

function CooldownViewerBuffBarItemMixin:SetTimerShown(shownSetting)
	local durationFontString = self:GetDurationFontString();
	if durationFontString then
		durationFontString:SetShown(shownSetting);
	end
end

function CooldownViewerBuffBarItemMixin:IsTimerShown()
	local durationFontString = self:GetDurationFontString();
	if durationFontString then
		return durationFontString:IsShown();
	end

	return false;
end

function CooldownViewerBuffBarItemMixin:RefreshCooldownInfo()
	local barFrame = self:GetBarFrame();
	local durationFontString = self:GetDurationFontString();
	local pipTexture = self:GetPipTexture();

	local expirationTime, duration, paused = self:GetCooldownValues();
	local currentTime = expirationTime - GetTime();

	if currentTime > 0 then
		barFrame:SetMinMaxValues(0, duration);
		barFrame:SetValue(currentTime);

		if durationFontString:IsShown() then
			local time = string.format(COOLDOWN_DURATION_SEC, currentTime);
			durationFontString:SetText(time);
		end

		pipTexture:SetShown(true);
	else
		barFrame:SetMinMaxValues(0, 0);
		barFrame:SetValue(0);

		if durationFontString:IsShown() then
			durationFontString:SetText("");
		end

		pipTexture:SetShown(false);
	end
end

function CooldownViewerBuffBarItemMixin:GetNameText()
	local totemData = self:GetTotemData();
	if totemData then
		return totemData.name;
	end

	local auraData = self:GetAuraData();
	if auraData then
		return auraData.name;
	end

	local spellID = self:GetSpellID();
	if spellID then
		return C_Spell.GetSpellName(spellID);
	end

	return "";
end

function CooldownViewerBuffBarItemMixin:RefreshName()
	local nameFontString = self:GetNameFontString();
	if not nameFontString:IsShown() then
		return;
	end

	local nameText = self:GetNameText();
	nameFontString:SetText(nameText);
end

function CooldownViewerBuffBarItemMixin:RefreshApplications()
	local applicationsText = self:GetApplicationsText();

	local applicationsFontString = self:GetApplicationsFontString();
	applicationsFontString:SetText(applicationsText);
end

function CooldownViewerBuffBarItemMixin:OnActiveStateChanged()
	CooldownViewerBuffItemMixin.OnActiveStateChanged(self);

	local active = self:IsActive();
	if active then
		self:RefreshName();
		self:SetScript("OnUpdate", self.OnUpdate);
	else
		self:SetScript("OnUpdate", nil);
	end
end

function CooldownViewerBuffBarItemMixin:RefreshData()
	self:RefreshAuraInstance();
	self:RefreshSpellTexture();
	self:RefreshCooldownInfo();
	self:RefreshName();
	self:RefreshApplications();
	self:RefreshActive();
end

---------------------------------------------------------------------------------------------------
local cooldownViewerEnabledCVar = "cooldownViewerEnabled";
CVarCallbackRegistry:SetCVarCachable(cooldownViewerEnabledCVar);

CooldownViewerMixin = {};

function CooldownViewerMixin:GetItemContainerFrame()
	return self;
end

function CooldownViewerMixin:GetItemFrames()
	local itemContainerFrame = self:GetItemContainerFrame();
	return itemContainerFrame:GetLayoutChildren();
end

function CooldownViewerMixin:OnLoad()
	EditModeSystemMixin.OnSystemLoad(self);

	local itemResetCallback = function(pool, itemFrame)
		Pool_HideAndClearAnchors(pool, itemFrame);
		itemFrame:ClearCooldownID();
		itemFrame.layoutIndex = nil;
	end;
	self.itemFramePool = CreateFramePool("FRAME", self:GetItemContainerFrame(), self.itemTemplate, itemResetCallback);

	self.iconLimit = 1;
	self.iconDirection = Enum.CooldownViewerIconDirection.Right;
	self.iconPadding = 5;
	self.isHorizontal = true;
	self.iconScale = 1;

	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_LEVEL_CHANGED");
	self:RegisterEvent("TRAIT_CONFIG_UPDATED");
	self:RegisterEvent("COOLDOWN_VIEWER_TABLE_HOTFIXED");
	
	EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", self.OnVariablesLoaded, self);
	CVarCallbackRegistry:RegisterCallback(cooldownViewerEnabledCVar, self.OnCooldownViewerEnabledCVarChanged, self);

	self:UpdateShownState();

	-- The edit mode selection indicator uses the bounds of the item container to more closely match the player's expectation.
	self.Selection:SetAllPoints(self:GetItemContainerFrame());
end

function CooldownViewerMixin:OnVariablesLoaded()
	self:UpdateShownState();
end

function CooldownViewerMixin:OnCooldownViewerEnabledCVarChanged()
	self:UpdateShownState();
end

function CooldownViewerMixin:OnEvent(event, ...)
	if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_LEVEL_CHANGED" then
		self:UpdateShownState();
	elseif event == "TRAIT_CONFIG_UPDATED" then
		self:RefreshLayout();
	elseif event == "COOLDOWN_VIEWER_TABLE_HOTFIXED" then
		self:RefreshLayout();
	end
end

function CooldownViewerMixin:ShouldBeShown()
	if self:IsEditing() then
		return true;
	end

	if CVarCallbackRegistry:GetCVarValueBool(cooldownViewerEnabledCVar) ~= true then
		return false;
	end

	if not C_CooldownViewer.IsCooldownViewerAvailable() then
		return false;
	end

	if self.visibleSetting then
		if self.visibleSetting == Enum.CooldownViewerVisibleSetting.Always then
			return true;
		elseif self.visibleSetting == Enum.CooldownViewerVisibleSetting.InCombat then
			local isInCombat = UnitAffectingCombat("player");
			return isInCombat;
		elseif self.visibleSetting == Enum.CooldownViewerVisibleSetting.Hidden then
			return false;
		else
			assertsafe(false, "Unknown value for visible setting: " .. self.visibleSetting);
		end
	end

	return true;
end

-- Override in derived mixins that need to know when this setting changes.
function CooldownViewerMixin:OnIsEditingChanged()
	self:UpdateShownState();
	self:RefreshLayout();
end

function CooldownViewerMixin:SetIsEditing(isEditing)
	if self.isEditing == isEditing then
		return;
	end

	self.isEditing = isEditing;

	self:OnIsEditingChanged();
end

function CooldownViewerMixin:IsEditing()
	return self.isEditing;
end

function CooldownViewerMixin:OnHideWhenInactiveChanged()
	if self.itemActiveStateChangedEvent then
		-- Only need to listen for the event if it will result in a layout change.
		if self.hideWhenInactive then
			EventRegistry:RegisterCallback(self.itemActiveStateChangedEvent, self.OnItemActiveStateChanged, self);
		else
			EventRegistry:UnregisterCallback(self.itemActiveStateChangedEvent, self);
		end

		-- Changes to the setting may result in items being shown or hidden.
		self:RefreshItemsShown();
	end
end

function CooldownViewerMixin:SetHideWhenInactive(hideWhenInactive)
	if self.hideWhenInactive == hideWhenInactive then
		return;
	end

	self.hideWhenInactive = hideWhenInactive;

	self:OnHideWhenInactiveChanged();
end

function CooldownViewerMixin:GetHideWhenInactive()
	return self.hideWhenInactive;
end

function CooldownViewerMixin:UpdateShownState()
	local shouldBeShown = self:ShouldBeShown();
	local isShown = self:IsShown();

	if shouldBeShown == isShown then
		return;
	end

	self:SetShown(shouldBeShown);

	if shouldBeShown then
		self:RefreshData();
	end
end

function CooldownViewerMixin:IsHorizontal()
	return self.orientationSetting == Enum.CooldownViewerOrientation.Horizontal;
end

function CooldownViewerMixin:GetItemCount()
	local cooldownIDs = self:GetCooldownIDs();
	local itemCount = cooldownIDs and #cooldownIDs or 0;

	if self:IsEditing() then
		local editModeMinimumItemCount = 2;
		itemCount = math.max(itemCount, editModeMinimumItemCount);
	end

	return itemCount;
end

function CooldownViewerMixin:GetStride()
	return self.iconLimit;
end

function CooldownViewerMixin:RefreshLayout()
	self.itemFramePool:ReleaseAll();

	local itemCount = self:GetItemCount();
	for i = 1, itemCount do
		local itemFrame = self.itemFramePool:Acquire();
		itemFrame:SetScale(self.iconScale);
		itemFrame.layoutIndex = i;
	end

	local itemContainerFrame = self:GetItemContainerFrame();

	-- Needed for changes to icon scale, which don't trigger a layout update.
	itemContainerFrame.alwaysUpdateLayout = true;

	itemContainerFrame.isHorizontal = self:IsHorizontal();

	-- Vertical layout is always left to right. Horizontal layout uses the Icon Direction.
	itemContainerFrame.layoutFramesGoingRight = not self.isHorizontal or (self.isHorizontal and self.iconDirection == Enum.CooldownViewerIconDirection.Right);
	
	-- Horizontal layout is always top to bottom. Vertical layout uses the Icon Direction.
	itemContainerFrame.layoutFramesGoingUp = not self.isHorizontal and self.iconDirection == Enum.CooldownViewerIconDirection.Right;
	
	itemContainerFrame.childXPadding = self.iconPadding;
	itemContainerFrame.childYPadding = self.iconPadding;

	itemContainerFrame.stride = self:GetStride();

	if self:IsShown() then
		self:RefreshData();
	end
end

function CooldownViewerMixin:GetCooldownIDs()
	assertsafe(self.cooldownViewerCategory, "Cooldown Viewer Category not set");
	return C_CooldownViewer.GetCooldownViewerCategorySet(self.cooldownViewerCategory);
end

function CooldownViewerMixin:RefreshData()
	local cooldownIDs = self:GetCooldownIDs();

	for itemFrame in self.itemFramePool:EnumerateActive() do
		local cooldownID = cooldownIDs and cooldownIDs[itemFrame.layoutIndex];
		if cooldownID then
			itemFrame:SetCooldownID(cooldownID);
		else
			itemFrame:ClearCooldownID();

			if self:IsEditing() then
				-- Generate a unique number for each item in edit mode that can be used to look up a placeholder texture or generate a fake duration.
				local editModeData = itemFrame.layoutIndex * 5 + self.cooldownViewerCategory;
				itemFrame:SetEditModeData(editModeData);
			else
				itemFrame:ClearEditModeData();
			end
		end
	end

	self:RefreshItemsShown();
end

function CooldownViewerMixin:OnItemActiveStateChanged(itemFrame)
	-- If a change in active state results in a change in shown state, then a layout is needed.
	if self:RefreshItemShown(itemFrame) then
		self:GetItemContainerFrame():Layout();
	end
end

function CooldownViewerMixin:ShouldItemBeShown(itemFrame)
	-- Show all items while editing so the player can see the contents of the UI.
	if self:IsEditing() then
		return true;
	end

	if self:GetHideWhenInactive() then
		return itemFrame:IsActive();
	end

	return true;
end

function CooldownViewerMixin:RefreshItemShown(itemFrame)
	local shouldItemBeShown = self:ShouldItemBeShown(itemFrame);
	local isItemShown = itemFrame:IsShown();

	itemFrame:SetShown(shouldItemBeShown);

	-- Return true if the shown state changed to indicate to the caller that a layout is needed.
	return shouldItemBeShown ~= isItemShown;
end

function CooldownViewerMixin:RefreshItemsShown()
	local needsLayout = false;

	for itemFrame in self.itemFramePool:EnumerateActive() do
		needsLayout = self:RefreshItemShown(itemFrame) or needsLayout;
	end

	-- Any item being shown or hidden requires a layout.
	if needsLayout then
		self:GetItemContainerFrame():Layout();
	end
end

function CooldownViewerMixin:SetTimerShown(shownSetting)
	for itemFrame in self.itemFramePool:EnumerateActive() do
		itemFrame:SetTimerShown(shownSetting);
	end
end

---------------------------------------------------------------------------------------------------
EssentialCooldownViewerMixin = CreateFromMixins(CooldownViewerMixin);

function EssentialCooldownViewerMixin:OnLoad()
	CooldownViewerMixin.OnLoad(self);
end

---------------------------------------------------------------------------------------------------
UtilityCooldownViewerMixin = CreateFromMixins(CooldownViewerMixin);

function UtilityCooldownViewerMixin:OnLoad()
	CooldownViewerMixin.OnLoad(self);
end

---------------------------------------------------------------------------------------------------
BuffIconCooldownViewerMixin = CreateFromMixins(CooldownViewerMixin);

function BuffIconCooldownViewerMixin:OnLoad()
	CooldownViewerMixin.OnLoad(self);
end

function BuffIconCooldownViewerMixin:GetStride()
	-- Ensure there is only ever one row/column (based on orientation)
	return self:GetItemCount();
end

---------------------------------------------------------------------------------------------------
BuffBarCooldownViewerMixin = CreateFromMixins(CooldownViewerMixin);

function BuffBarCooldownViewerMixin:OnLoad()
	CooldownViewerMixin.OnLoad(self);
end

function BuffBarCooldownViewerMixin:GetStride()
	-- Ensure there is only ever one row/column (based on orientation)
	return self:GetItemCount();
end

function BuffBarCooldownViewerMixin:SetBarContent(barContent)
	for itemFrame in self.itemFramePool:EnumerateActive() do
		itemFrame:SetBarContent(barContent);
	end
end
