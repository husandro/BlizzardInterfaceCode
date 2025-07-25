local arenaFrames;

InspectPvpTalentSlotMixin = CreateFromMixins(PvpTalentSlotMixin);

function InspectPvpTalentSlotMixin:OnLoad()
	self.Texture:SetSize(34, 34);
end

function InspectPvpTalentSlotMixin:Update()
	if (not self.slotIndex) then
		error("Slot must be setup with a slot index first.");
	end

	if (not INSPECTED_UNIT) then
		return;
	end

	local selectedTalentID = C_SpecializationInfo.GetInspectSelectedPvpTalent(INSPECTED_UNIT, self.slotIndex);

	if (selectedTalentID) then
		SetPortraitToTexture(self.Texture, select(3, GetPvpTalentInfoByID(selectedTalentID)));
		self.Texture:Show();
		self.talentID = selectedTalentID;
	else
		self.Texture:Hide();
	end
end

function InspectPvpTalentSlotMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if (self.talentID) then
		local IS_INSPECT = true;
		GameTooltip:SetPvpTalent(self.talentID, IS_INSPECT);
	else
		GameTooltip:SetText(TALENT_NOT_SELECTED, HIGHLIGHT_FONT_COLOR:GetRGB());
	end
	GameTooltip:Show();
end

function InspectPvpTalentSlotMixin:OnClick()
	if (IsModifiedClick("CHATLINK") and self.talentID) then
		local link = GetPvpTalentLink(self.talentID);
		if (link) then
			ChatEdit_InsertLink(link);
		end
	end
end

function InspectPVPFrame_OnLoad(self)
	self:RegisterEvent("INSPECT_HONOR_UPDATE");
	self.inspect = true;
	arenaFrames = {InspectPVPFrame.Arena2v2, InspectPVPFrame.Arena3v3};
	for i, slot in ipairs(self.Slots) do
		slot:SetUp(i);
	end
end

function InspectPVPFrame_OnEvent(self, event, ...)
	if ( event == "INSPECT_HONOR_UPDATE" ) then
		InspectPVPFrame_Update();
	end
end

function InspectPVPFrame_OnShow()
	ButtonFrameTemplate_HideButtonBar(InspectFrame);
	InspectPVPFrame_Update();
end

function InspectPVPFrame_Update()
	local parent = InspectPVPFrame:GetParent();
	local factionGroup = UnitFactionGroup(INSPECTED_UNIT);
	local _, _, _, _, lifetimeHKs, _, honorLevel = GetInspectHonorData();
	local level = UnitLevel(INSPECTED_UNIT);

	InspectPVPFrame.HKs:SetFormattedText(INSPECT_HONORABLE_KILLS, lifetimeHKs);

	if not C_SpecializationInfo.CanPlayerUsePVPTalentUI() then
		InspectPVPFrame.SmallWreath:Hide();
		InspectPVPFrame.HonorLevel:Hide();
		InspectPVPFrame.RatedBG:Hide();
		InspectPVPFrame.RatedSoloShuffle:Hide();
		InspectPVPFrame.RatedBGBlitz:Hide();
		for i = 1, MAX_ARENA_TEAMS do
			arenaFrames[i]:Hide();
		end
	else
		InspectPVPFrame.SmallWreath:SetShown(false);
		InspectPVPFrame.HonorLevel:SetFormattedText(HONOR_LEVEL_LABEL, honorLevel);
		InspectPVPFrame.HonorLevel:Show();
		local ratedBGData = C_PaperDollInfo.GetInspectRatedBGData();
		InspectPVPFrame.RatedBG.Rating:SetText(ratedBGData.rating);
		InspectPVPFrame.RatedBG.Record:SetFormattedText(PVP_RECORD_DESCRIPTION, ratedBGData.won, (ratedBGData.played - ratedBGData.won));
		InspectPVPFrame.RatedBG:Show();
		for i=1, MAX_ARENA_TEAMS do
			local arenarating, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon = GetInspectArenaData(i);
			local frame = arenaFrames[i];
			frame.Rating:SetText(arenarating);
			frame.Record:SetFormattedText(PVP_RECORD_DESCRIPTION, seasonWon, (seasonPlayed - seasonWon));
			frame:Show();
		end

		local ratedSoloShuffleStats = C_PaperDollInfo.GetInspectRatedSoloShuffleData();
		InspectPVPFrame.RatedSoloShuffle.Rating:SetText(ratedSoloShuffleStats.rating);
		InspectPVPFrame.RatedSoloShuffle.Record:SetFormattedText(PVP_RECORD_DESCRIPTION, ratedSoloShuffleStats.roundsWon, (ratedSoloShuffleStats.roundsPlayed - ratedSoloShuffleStats.roundsWon));
		InspectPVPFrame.RatedSoloShuffle:Show();

		local ratedBGBlitzStats = C_PaperDollInfo.GetInspectRatedBGBlitzData();
		InspectPVPFrame.RatedBGBlitz.Rating:SetText(ratedBGBlitzStats.rating);
		InspectPVPFrame.RatedBGBlitz.Record:SetFormattedText(PVP_RECORD_DESCRIPTION, ratedBGBlitzStats.gamesWon, (ratedBGBlitzStats.gamesPlayed - ratedBGBlitzStats.gamesWon));
		InspectPVPFrame.RatedBGBlitz:Show();
		
		InspectPVPFrame.talentGroup = C_SpecializationInfo.GetActiveSpecGroup(true);
		for i, slot in ipairs(InspectPVPFrame.Slots) do
			slot:Update();
		end
	end
end

function InspectPvPTalentFrameTalent_OnEnter(self)
	local classDisplayName, class, classID = UnitClass(INSPECTED_UNIT);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");	
	GameTooltip:SetPvpTalent(self.pvpTalentID, true, self.talentGroup);
end

function InspectPvPTalentFrameTalent_OnClick(self)
	if ( IsModifiedClick("CHATLINK") ) then
		ChatEdit_InsertLink(GetPvpTalentLink(self.pvpTalentID));
	end
end
