----------------------------
---------Constants----------
----------------------------
QUICK_JOIN_NAME_SEPARATION = 5;
ROLE_SELECTION_PROMPT_DEFAULT_HEIGHT = 160;

----------------------------
-------QuickJoinFrame-------
----------------------------
QuickJoinMixin = CreateFromMixins();

do
	local dynamicEvents = {
		"SOCIAL_QUEUE_UPDATE",
		"GROUP_JOINED",
		"GROUP_LEFT",
		"LFG_LIST_SEARCH_RESULT_UPDATED",
		"PVP_BRAWL_INFO_UPDATED",
		"GUILD_ROSTER_UPDATE",
	};

	function QuickJoinMixin:OnLoad()
		local view = CreateScrollBoxListLinearView();
		view:SetElementInitializer("QuickJoinButtonTemplate", function(button, elementData)
			button:Init(elementData);
		end);

		-- Scrollable text in the Quick Join List can be resized by the player so the extent may change during a session
		view:SetElementExtentCalculator(function(dataIndex, elementData)
			return elementData:CalculateHeight();
		end);

		ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

		self.entries = CreateFromMixins(QuickJoinEntriesMixin);
		self.entries:Init();

		self:UpdateScrollFrame();
	end

	function QuickJoinMixin:OnShow()
		EventRegistry:RegisterCallback("TextSizeManager.OnTextScaleUpdated", function()
			self:UpdateScrollFrame();
		end);

		FrameUtil.RegisterFrameForEvents(self, dynamicEvents);
		self.entries:UpdateAll();
		self:SelectGroup(nil);
		self:UpdateScrollFrame();

		FriendsFrame_CloseQuickJoinHelpTip();
	end

	function QuickJoinMixin:OnHide()
		EventRegistry:UnregisterCallback("TextSizeManager.OnTextScaleUpdated", self);
		FrameUtil.UnregisterFrameForEvents(self, dynamicEvents);
	end
end

function QuickJoinMixin:OnEvent(event, ...)
	if ( event == "SOCIAL_QUEUE_UPDATE" ) then
		local requester = ...;
		self:UpdateEntry(requester);
	elseif ( event == "LFG_LIST_SEARCH_RESULT_UPDATED" ) then
		local lfgListID = ...;
		local guid = self.entries:GetEntryGUIDByLFGListID(lfgListID);
		if ( guid ) then
			self:UpdateEntry(guid);
		end
	elseif ( event == "GROUP_JOINED" ) then
		local index, guid = ...;
		self.entries:UpdateEntry(guid);

		self:UpdateScrollFrame();
		self:UpdateJoinButtonState();
	elseif ( event == "GROUP_LEFT" ) then
		local guid = ...;
		self.entries:UpdateEntry(guid);

		self:UpdateScrollFrame();
		self:UpdateJoinButtonState();
	elseif ( event == "PVP_BRAWL_INFO_UPDATED") then
		self:RefreshEntries();
	elseif ( event == "GUILD_ROSTER_UPDATE" ) then
		local canRequestGuildRoster = ...;
		if ( canRequestGuildRoster ) then
			C_GuildInfo.GuildRoster();
		end

		self:UpdateScrollFrame();
	end
end

function QuickJoinMixin:RefreshEntries()
	for guid, entry in pairs(self.entries.entriesByGUID) do
		self:UpdateEntry(guid);
	end
end

function QuickJoinMixin:UpdateEntry(guid)
	self.entries:UpdateEntry(guid);

	if ( guid == self:GetSelectedGroup() ) then
		local entry = self.entries:GetEntry(guid);
		if ( entry and not entry:CanJoin() ) then
			self:SelectGroup(nil);
		end
	end

	self:UpdateScrollFrame();
end

function QuickJoinMixin:UpdateScrollFrame()
	local entries = self.entries:GetEntries();
	local dataProvider = CreateDataProvider(entries);
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function QuickJoinMixin:SelectGroup(guid)
	local oldSelectedGUID = self.selectedGUID;
	self.selectedGUID = guid;

	self:UpdateScrollFrame();
	self:UpdateJoinButtonState();

	local function UpdateButtonSelection(guid, selected)
		if guid then
			local button = self.ScrollBox:FindFrameByPredicate(function(button, elementData)
				return elementData.guid == guid;
			end);
			if button then
				button:SetSelected(selected);
			end
		end
	end;
	
	UpdateButtonSelection(oldSelectedGUID, false);
	UpdateButtonSelection(guid, true);
end

function QuickJoinMixin:ScrollToGroup(guid)
	self.ScrollBox:ScrollToElementData(function(elementData)
		return elementData.guid == guid;
	end);
end

function QuickJoinMixin:GetSelectedGroup()
	return self.selectedGUID;
end

function QuickJoinMixin:JoinQueue()
	local selectedEntry = self.entries:GetEntry(self.selectedGUID);
	if ( selectedEntry ) then
		selectedEntry:AttemptJoin();
	end
end

function QuickJoinMixin:UpdateJoinButtonState()
	-- Request To Join as our default button text if nothing is selected.
	self.JoinQueueButton:SetText(JOIN_QUEUE);

	if ( IsInGroup(LE_PARTY_CATEGORY_HOME) ) then
		self.JoinQueueButton:Disable();
		self.JoinQueueButton.tooltip = QUICK_JOIN_ALREADY_IN_PARTY;
	elseif ( self:GetSelectedGroup() == nil ) then
		self.JoinQueueButton:Disable();
		self.JoinQueueButton.tooltip = nil;
	else
		self.JoinQueueButton:Enable();
		self.JoinQueueButton.tooltip = nil;

		local queues = C_SocialQueue.GetGroupQueues(self:GetSelectedGroup());
		if ( queues and queues[1] and queues[1].queueData.queueType == "lfglist" ) then
			self.JoinQueueButton:SetText(SIGN_UP);
		end
	end
end

function QuickJoinMixin:OpenContextMenu(quickJoinButton, overrideMemberInfo)
	local memberInfo = overrideMemberInfo or quickJoinButton.Members[1];
	if not memberInfo.playerLink then
		return;
	end

	MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
		rootDescription:SetTag("MENU_QUICK_JOIN");

		rootDescription:CreateTitle(memberInfo.name);
		rootDescription:CreateButton(WHISPER, function()
			local link, text = LinkUtil.SplitLink(memberInfo.playerLink);
			SetItemRef(link, text, "LeftButton");
		end);
	end);
end

----------------------------
------QuickJoinButton------
----------------------------
QuickJoinButtonMixin = {}

function QuickJoinButtonMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function QuickJoinButtonMixin:GetMainPanel()
	return QuickJoinFrame;
end

function QuickJoinButtonMixin:SetEntry(entry)
	entry:ApplyToFrame(self);
	self.entry = entry;
end

function QuickJoinButtonMixin:GetEntry()
	return self.entry;
end

function QuickJoinButtonMixin:Init(elementData)
	self.fontObject = elementData.fontObject;
	self:SetEntry(elementData);
	local selected = self:GetEntry():GetGUID() == QuickJoinFrame.selectedGUID;
	self:SetSelected(selected);
end

function QuickJoinButtonMixin:SetSelected(selected)
	self.Selected:SetShown(selected);
	self.Highlight:SetAlpha(selected and 0 or 0.5);
end

function QuickJoinButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	self:GetEntry():ApplyToTooltip(GameTooltip);
	GameTooltip:Show();
	if ( self:GetEntry():CanJoin() ) then
		self.Highlight:Show();
	end
end

function QuickJoinButtonMixin:OnLeave()
	GameTooltip:Hide();
	self.Highlight:Hide();
end

function QuickJoinButtonMixin:OnClick(button)
	if ( button == "LeftButton" ) then
		if ( self:GetEntry():CanJoin() ) then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
			self:GetMainPanel():SelectGroup(self:GetEntry():GetGUID());
		end
	elseif ( button == "RightButton" ) then
		self:OpenContextMenu();
	end
end

function QuickJoinButtonMixin:FindMemberInfoForLink(link)
	for _, memberInfo in ipairs(self.Members) do
		if memberInfo.playerLink:find(link, 1, true) then
			return memberInfo;
		end
	end

	return nil;
end

function QuickJoinButtonMixin:OnHyperlinkClick(link, text, button)
	if ( button == "RightButton" ) then
		self:OpenContextMenu(self:FindMemberInfoForLink(link));
	else
		-- Forward click to the QuickJoin row
		self:OnClick(button);
	end
end

function QuickJoinButtonMixin:OpenContextMenu(overrideMemberInfo)
	self:GetMainPanel():OpenContextMenu(self, overrideMemberInfo);
end

----------------------------
------QuickJoinEntries------
----------------------------
QuickJoinEntriesMixin = {}

function QuickJoinEntriesMixin:Init()
	self:UpdateAll();
end

function QuickJoinEntriesMixin:GetEntries()
	return self.entries;
end

function QuickJoinEntriesMixin:GetEntry(guid)
	return self.entriesByGUID[guid];
end

function QuickJoinEntriesMixin:GetEntryGUIDByLFGListID(lfgListID)
	for guid, entry in pairs(self.entriesByGUID) do
		local info = entry:GetActiveLFGListInfo();
		if ( info and info.clientID == lfgListID ) then
			return guid;
		end
	end
end

function QuickJoinEntriesMixin:UpdateAll()
	local groups = C_SocialQueue.GetAllGroups();
	self.entries = {};
	self.entriesByGUID = {};
	for i=1, #groups do
			local entry = CreateFromMixins(QuickJoinEntryMixin);
			entry:Init(groups[i]);
		self.entries[i] = entry;
			self.entriesByGUID[groups[i]] = entry;
		end

	--Sort?
	--table.sort(self.entries, SOMETHING);
end

function QuickJoinEntriesMixin:UpdateEntry(requester)
	local entry = self.entriesByGUID[requester];
	if ( entry ) then
		entry:Update();
	else
		local canJoin, numQueues = C_SocialQueue.GetGroupInfo(requester);
		if ( canJoin and numQueues and numQueues > 0 ) then
			--Just add the new one to the end
			entry = CreateFromMixins(QuickJoinEntryMixin);
			entry:Init(requester);
			self.entries[#self.entries+1] = entry;
			self.entriesByGUID[requester] = entry;
		end
	end
end

----------------------------
-------QuickJoinEntry-------
----------------------------
QuickJoinEntryMixin = {}

function QuickJoinEntryMixin:Init(partyGUID)
	-- All scrollable text in the Quick Join List uses font that can be resized by the player
	self.fontObject = UserScaledFontGameNormalSmall;

	self.guid = partyGUID;
	self:UpdateAll();
end

function QuickJoinEntryMixin:GetGUID()
	return self.guid;
end

function QuickJoinEntryMixin:UpdateAll()
	self.displayedMembers = {};
	self.displayedQueues = {};
	self:Update();

	SocialQueueUtil_SortGroupMembers(self.displayedMembers);
end

local function guidIDGetter(playerInfo)
	return playerInfo.guid; --Guids are unique identifying information as-is.
end

local function queueIDGetter(queue)
	return queue.clientID;
end

function QuickJoinEntryMixin:Update()
	local newMembers = C_SocialQueue.GetGroupMembers(self.guid) or {};
	local newQueues = C_SocialQueue.GetGroupQueues(self.guid) or {};

	self.zombieMemberIndices = self:BackfillAndUpdateFields(newMembers, self.displayedMembers, guidIDGetter);
	self.zombieQueueIndices = self:BackfillAndUpdateFields(newQueues, self.displayedQueues, queueIDGetter);
	for i, queue in ipairs(self.displayedQueues) do
		if ( self.zombieQueueIndices[i] ) then
			queue.isZombie = true;
		else
			queue.isZombie = false;
		end
	end

	local canJoin, numQueues = C_SocialQueue.GetGroupInfo(self.guid);
	self.canJoin = canJoin and numQueues and numQueues > 0;
	self:UpdateLeader();

	--Cache off names of groups in case we lose the information to get them later
	for i=1, #self.displayedQueues do
		local queue = self.displayedQueues[i];
		local queueName = SocialQueueUtil_GetQueueName(queue.queueData);
		if ( queueName ) then
			queue.cachedQueueName = queueName;
		end
	end
end

function QuickJoinEntryMixin:CanJoin()
	return self.canJoin;
end

function QuickJoinEntryMixin:UpdateLeader()
	self.hasRelationshipWithLeader = SocialQueueUtil_HasRelationshipWithLeader(self.guid);
end

function QuickJoinEntryMixin:HasLocalRelationshipWithLeader()
	return self.hasRelationshipWithLeader;
end

function QuickJoinEntryMixin:BackfillAndUpdateFields(newList, oldList, idGetter)
	local toDisplay = {};
	for k, v in pairs(newList) do
		toDisplay[idGetter(v)] = v;
	end

	local slotsToFillIn = {};
	for i=#oldList, 1, -1 do
		local id = idGetter(oldList[i]);
		if ( toDisplay[id] ) then
			oldList[i] = toDisplay[id]; --Update the data
			toDisplay[id] = nil;
		else
			slotsToFillIn[#slotsToFillIn + 1] = i;
		end
	end

	for dataID, dataValue in pairs(toDisplay) do
		if ( #slotsToFillIn > 0 ) then
			local fillIn = slotsToFillIn[#slotsToFillIn];
			oldList[fillIn] = dataValue;
			slotsToFillIn[#slotsToFillIn] = nil;
		else
			oldList[#oldList + 1] = dataValue;
		end
	end

	return tInvert(slotsToFillIn);
end

function QuickJoinEntryMixin:GetActiveLFGListInfo()
	for i, queueInfo in ipairs(self.displayedQueues) do
		if ( not self.zombieQueueIndices[i] ) then
			if ( queueInfo.queueData.queueType == "lfglist" ) then
				return queueInfo;
			end
		end
	end
end

function QuickJoinEntryMixin:AttemptJoin()
	local lfgListInfo = self:GetActiveLFGListInfo();
	if ( lfgListInfo ) then
		LFGListApplicationDialog_Show(LFGListApplicationDialog, lfgListInfo.queueData.lfgListID);
	else
		QuickJoinRoleSelectionFrame:ShowForGroup(self:GetGUID());
	end
end

function QuickJoinEntryMixin:ApplyToTooltip(tooltip)
	local members = self.displayedMembers;
	if ( not members ) then
		GMError("Applying quick join entry to tooltip with no members.");
		return;
	end

	SocialQueueUtil_SetTooltip(tooltip, SocialQueueUtil_GetHeaderName(self.guid), self.displayedQueues, self:CanJoin(), self:HasLocalRelationshipWithLeader());
end

local MAX_NUM_DISPLAYED_QUEUES = 6;
function QuickJoinEntryMixin:ApplyToFrame(frame)
	--Names
	for i=1, #self.displayedMembers do
		local name, color, relationship, playerLink = SocialQueueUtil_GetRelationshipInfo(self.displayedMembers[i].guid, nil, self.displayedMembers[i].clubId);
		local nameObj = frame.Members[i];
		if ( not nameObj ) then
			nameObj = frame:CreateFontString(nil, "ARTWORK", "QuickJoinButtonMemberTemplate");
			nameObj:SetPoint("TOPLEFT", frame.Members[i-1], "BOTTOMLEFT", 0, -QUICK_JOIN_NAME_SEPARATION);
			frame.Members[i] = nameObj;
		end

		nameObj.playerLink = playerLink;
		nameObj.name = name;

		if ( i < #self.displayedMembers ) then
			name = name..",";
		end

		local displayName = playerLink or name;
		if ( self.zombieMemberIndices[i] or not self:CanJoin() ) then
			name = ("%s%s|r"):format(DISABLED_FONT_COLOR_CODE, displayName);
		else
			--Use the color code for our relationship
			name = ("%s%s|r"):format(color, displayName);
		end

		nameObj:SetText(name);
		nameObj:Show();
	end

	for i=#self.displayedMembers + 1, #frame.Members do
		frame.Members[i]:Hide();
	end

	-- Queue Icon
	local useGroupIcon = #self.displayedQueues > 0 and self.displayedQueues[1].queueData.queueType == "lfglist";
	frame.Icon:SetAtlas(useGroupIcon and "socialqueuing-icon-group" or "socialqueuing-icon-eye");
	-- Set the height based on the size of the member names...
	frame.Icon:SetHeight(math.max(17, frame.MemberName:GetHeight()));
	-- ...then set the width based on that height
	frame.Icon:SetWidth(math.max(16, frame.Icon:GetHeight() * .95));

	--Queues
	local groupIsJoinable = self:CanJoin();

	frame.QueueName:SetPoint("TOPLEFT", frame.MemberName, "TOPRIGHT", frame.Icon:GetWidth() + 4, 0);
	for i=1, #self.displayedQueues do
		local queue = self.displayedQueues[i];

		local queueObj = frame.Queues[i];
		if ( not queueObj ) then
			queueObj = frame:CreateFontString(nil, "ARTWORK", "QuickJoinButtonQueueTemplate");
			queueObj:SetPoint("TOPLEFT", frame.Queues[i-1], "BOTTOMLEFT", 0, -QUICK_JOIN_NAME_SEPARATION);
			frame.Queues[i] = queueObj;
		end

		if ( i == MAX_NUM_DISPLAYED_QUEUES and i ~= #self.displayedQueues ) then
			local color = "|cffcccccc";
			if ( not groupIsJoinable ) then
				color = DISABLED_FONT_COLOR_CODE;
			end
			local truncatedLine = string.format(color.."+%d"..FONT_COLOR_CODE_CLOSE, 1 + #self.displayedQueues - MAX_NUM_DISPLAYED_QUEUES);
			queueObj:SetText(truncatedLine);
			queueObj:Show();
			break;
		end

		local queueName = queue.cachedQueueName;

		if ( not queueName ) then
			GMError("No queue name found");
		else
			if ( self.displayedQueues[i].queueData.queueType == "lfglist" ) then
				queueName = string.format(LFG_LIST_IN_QUOTES, queueName);
			end

			if ( i < #self.displayedQueues ) then
				queueName = queueName..PLAYER_LIST_DELIMITER;
			end

			if ( self.zombieQueueIndices[i] or not self:CanJoin() ) then
				queueName = DISABLED_FONT_COLOR_CODE..queueName..FONT_COLOR_CODE_CLOSE;
			end
		end
		queueObj:SetText(queueName);
		queueObj:Show();
	end

	if ( groupIsJoinable ) then
		frame.Icon:SetDesaturation(0);
		frame.Icon:SetAlpha(0.9);
	else
		frame.Icon:SetDesaturation(1);
		frame.Icon:SetAlpha(0.3);
	end

	for i=#self.displayedQueues + 1, #frame.Queues do
		frame.Queues[i]:Hide();
	end

	frame:SetHeight(self:CalculateHeight());
end

function QuickJoinEntryMixin:CalculateHeight()
	local bufferHeight = 13;
	local height = (GetFontInfo(self.fontObject).height + QUICK_JOIN_NAME_SEPARATION);
	local namesHeight = height * #self.displayedMembers;
	local queuesHeight = height * min(#self.displayedQueues, MAX_NUM_DISPLAYED_QUEUES)
	return bufferHeight + math.max(namesHeight, queuesHeight);
end

----------------------------
---QuickJoinRoleSelection---
----------------------------
QuickJoinRoleSelectionMixin = {};

function QuickJoinRoleSelectionMixin:ShowForGroup(guid)
	self.guid = guid;
	local canJoin, numQueues, needTank, needHealer, needDamage = C_SocialQueue.GetGroupInfo(guid);
	self:SetDisabledRoles(
		not needTank and QUICK_JOIN_ROLE_NOT_NEEDED,
		not needHealer and QUICK_JOIN_ROLE_NOT_NEEDED,
		not needDamage and QUICK_JOIN_ROLE_NOT_NEEDED
	);

	if ( WillAcceptInviteRemoveQueues() ) then
		self.QueueWarningText:Show();
		self:SetHeight(ROLE_SELECTION_PROMPT_DEFAULT_HEIGHT + self.QueueWarningText:GetHeight() + 8);
	else
		self.QueueWarningText:Hide();
		self:SetHeight(ROLE_SELECTION_PROMPT_DEFAULT_HEIGHT);
	end
	StaticPopupSpecial_Show(self);
end

function QuickJoinRoleSelectionMixin:OnAccept()
	if ( not C_SocialQueue.RequestToJoin(self.guid, self:GetSelectedRoles()) ) then
		UIErrorsFrame:AddMessage(QUICK_JOIN_FAILED, 1.0, 0.1, 0.1, 1.0);
	end
	StaticPopupSpecial_Hide(self);
end

function QuickJoinRoleSelectionMixin:OnCancel()
	StaticPopupSpecial_Hide(self);
end

----------------------------
--Things that don't need their own mixins
----------------------------
function QuickJoin_JoinQueueButtonOnClick(self)
	local quickJoin = self:GetParent();
	quickJoin:JoinQueue();
end