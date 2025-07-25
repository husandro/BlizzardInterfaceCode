function UIParent_Shared_OnLoad(self)
	self:RegisterEvent("REPORT_PLAYER_RESULT");
end

local sendReportResultToErrorString = {
	[Enum.SendReportResult.Success] = ERR_REPORT_SUBMITTED_SUCCESSFULLY,
	[Enum.SendReportResult.GeneralError] = ERR_REPORT_SUBMISSION_FAILED,
	[Enum.SendReportResult.TooManyReports] = REPORT_RESULT_TOO_MANY_REPORTS,
	[Enum.SendReportResult.RequiresChatLine] = REPORT_RESULT_REQUIRES_CHAT,
	[Enum.SendReportResult.RequiresChatLineOrVoice] = REPORT_RESULT_REQUIRES_CHAT_OR_VOICE,
};

local function GetErrorMessageFromSendReportResult(result)
	return sendReportResultToErrorString[result] or ERR_REPORT_SUBMISSION_FAILED;
end

local sendReportResultToChatString = {
	[Enum.SendReportResult.Success] = COMPLAINT_ADDED,
	[Enum.SendReportResult.GeneralError] = ERR_REPORT_SUBMISSION_FAILED,
	[Enum.SendReportResult.TooManyReports] = REPORT_RESULT_TOO_MANY_REPORTS,
	[Enum.SendReportResult.RequiresChatLine] = REPORT_RESULT_REQUIRES_CHAT,
	[Enum.SendReportResult.RequiresChatLineOrVoice] = REPORT_RESULT_REQUIRES_CHAT_OR_VOICE,
};

local function GetChatMessageFromSendReportResult(result)
	return sendReportResultToChatString[result] or ERR_REPORT_SUBMISSION_FAILED;
end

function UIParent_Shared_OnEvent(self, event, ...)
	if event == "REPORT_PLAYER_RESULT" then
		local result = ...;
		UIErrorsFrame:AddExternalErrorMessage(GetErrorMessageFromSendReportResult(result));
		DEFAULT_CHAT_FRAME:AddMessage(GetChatMessageFromSendReportResult(result));
	end
end

function OpenAchievementFrameToAchievement(achievementID)
	if ( not AchievementFrame ) then
		AchievementFrame_LoadUI();
	end
	if ( not AchievementFrame:IsShown() ) then
		AchievementFrame_ToggleAchievementFrame(false, C_AchievementInfo.IsGuildAchievement(achievementID));
	end

	AchievementFrame_SelectAchievement(achievementID);
end

function ToggleLFGFrame()
	if (C_LFGList.GetPremadeGroupFinderStyle() == Enum.PremadeGroupFinderStyle.Vanilla) then
		if (not C_AddOns.IsAddOnLoaded("Blizzard_GroupFinder_VanillaStyle")) then
			return;
		end

		ToggleLFGParentFrame();
	else
		PVEFrame_ToggleFrame();
	end
end

function ReverseQuestObjective(text, objectiveType)
	if ( objectiveType == "spell" ) then
		return text;
	end
	local _, _, arg1, arg2 = string.find(text, "(.*):%s(.*)");
	if ( arg1 and arg2 ) then
		return arg2.." "..arg1;
	else
		return text;
  end
end

-- Note: Numeric abbreviation data is presently defined in game-specific files.
NUMBER_ABBREVIATION_DATA = {};

function GetLocalizedNumberAbbreviationData()
	return NUMBER_ABBREVIATION_DATA;
end

function AbbreviateNumbers(value)
	for i, data in ipairs(GetLocalizedNumberAbbreviationData()) do
		if value >= data.breakpoint then
			local finalValue = math.floor(value / data.significandDivisor) / data.fractionDivisor;
			return finalValue .. data.abbreviation;
		end
	end
	return tostring(value);
end

UIParentManagedFrameMixin = { };
function UIParentManagedFrameMixin:OnShow()
	self.layoutParent:AddManagedFrame(self);
end

function UIParentManagedFrameMixin:OnHide()
	self.layoutParent:RemoveManagedFrame(self);
end

local function IsActionBarOverriden()
	return OverrideActionBar and OverrideActionBar:IsShown() or false;
end

local function UpdateFrameAlphaState(frame, isActionBarOverriden)
	if frame.hideWhenActionBarIsOverriden then
		local setToAlpha = isActionBarOverriden and 0 or 1;
		frame:SetAlpha(setToAlpha);

		-- Since the frame isn't actually hidden, give it a way to remove itself from layout
		-- if that's the desired behavior.
		if frame.ignoreInLayoutWhenActionBarIsOverriden then
			frame.ignoreInLayout = isActionBarOverriden;
		end
	end
end

UIParentManagedFrameContainerMixin = {};

function UIParentManagedFrameContainerMixin:OnLoad()
	self.showingFrames = {};
end

function UIParentManagedFrameContainerMixin:UpdateFrame(frame)
	frame:ClearAllPoints();
	frame:SetParent(frame.layoutOnBottom and self.BottomManagedLayoutContainer or self);
	self:Layout();
	self.BottomManagedLayoutContainer:Layout();

	if frame.isRightManagedFrame and ObjectiveTrackerFrame then
		ObjectiveTrackerFrame:UpdateHeight();
	end
end

function UIParentManagedFrameContainerMixin:AddManagedFrame(frame)
	if frame.ignoreFramePositionManager then
		return;
	end

	if frame.IsInDefaultPosition and not frame:IsInDefaultPosition() then
		return;
	end

	if not frame:IsShown() then
		return;
	end

	-- If the frame is being added to the list while the override action bar is shown it needs to
	-- have its alpha value updated.
	local isActionBarOverriden = IsActionBarOverriden();
	if isActionBarOverriden and not self.showingFrames[frame] then
		UpdateFrameAlphaState(frame, isActionBarOverriden);
	end

	self.showingFrames[frame] = frame;
	self:UpdateFrame(frame);
end

function UIParentManagedFrameContainerMixin:UpdateManagedFrames()
	for _, frame in pairs(self.showingFrames) do
		if frame then
			self:UpdateFrame(frame);
		end
	end

	self:AnimInManagedFrames();
end

function UIParentManagedFrameContainerMixin:ClearManagedFrames()
	self:AnimOutManagedFrames();
end

function UIParentManagedFrameContainerMixin:RemoveManagedFrame(frame)
	if not self.showingFrames[frame] then
		return;
	end
	self.showingFrames[frame] = nil;

	if not frame.IsInDefaultPosition then
		frame:ClearAllPoints();
	end

	if ObjectiveTrackerFrame then
		ObjectiveTrackerFrame:UpdateHeight();
	end

	local isActionBarOverriden = IsActionBarOverriden();
	if isActionBarOverriden then
		-- A managed frame flagged to be hidden when the action bar is overridden should no longer be
		-- hidden if it's no longer managed. Otherwise it can be stuck in a hidden state.
		local isActionBarOverridenForFrame = false;
		UpdateFrameAlphaState(frame, isActionBarOverridenForFrame);
	end

	self:Layout();
	self.BottomManagedLayoutContainer:Layout();
end

function UIParentManagedFrameContainerMixin:UpdateManagedFramesAlphaState()
	local isActionBarOverriden = IsActionBarOverriden();
	for frame in pairs(self.showingFrames) do
		UpdateFrameAlphaState(frame, isActionBarOverriden);
	end
end

--Aubrie TODO determine if we want to actually apply a fade out for pet battles?
function UIParentManagedFrameContainerMixin:AnimOutManagedFrames()
	for frame in pairs(self.showingFrames) do
		frame:SetAlpha(0);
	end
end

function UIParentManagedFrameContainerMixin:AnimInManagedFrames()
	for frame in pairs(self.showingFrames) do
		frame:SetAlpha(1);
	end
end
