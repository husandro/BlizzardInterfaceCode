function FlowContainer_Initialize(container)
	FlowContainer_RemoveAllObjects(container);

	--Default orientation to horizontal for now.
	FlowContainer_SetOrientation(container, "horizontal");

	--So far, we haven't actually used any space.
	container.flowMaxPrimaryUsed = 0;
	container.flowMaxSecondaryUsed = 0;
end

function FlowContainer_PauseUpdates(container)
	container.flowPauseUpdates = true;
end

function FlowContainer_ResumeUpdates(container)
	container.flowPauseUpdates = false;
	FlowContainer_DoLayout(container);
end

function FlowContainer_SetOrientation(container, orientation)	--"vertical" or "horizontal". This is the direction it tries to fill first.
	container.flowOrientation = orientation;
	FlowContainer_DoLayout(container);
end

function FlowContainer_SetMaxPerLine(container, maxPerLine)	--nil means we fit as much as possible.
	container.flowMaxPerLine = maxPerLine;
	FlowContainer_DoLayout(container);
end

function FlowContainer_SetHorizontalSpacing(container, horizontalSpacing)
	container.flowHorizontalSpacing = horizontalSpacing;
	FlowContainer_DoLayout(container);
end

function FlowContainer_SetVerticalSpacing(container, verticalSpacing)
	container.flowVerticalSpacing = verticalSpacing;
	FlowContainer_DoLayout(container);
end

function FlowContainer_AddObject(container, object)
	tinsert(container.flowFrames, object);	--Do we want to let people choose where it will appear?
	tinsert(container.flowFrameTypes, "object");
	FlowContainer_DoLayout(container);
end

function FlowContainer_AddLineBreak(container)
	tinsert(container.flowFrames, "linebreak");
	tinsert(container.flowFrameTypes, "linebreak");
	FlowContainer_DoLayout(container);
end

function FlowContainer_AddSpacer(container, spacerSize)
	tinsert(container.flowFrames, spacerSize);
	tinsert(container.flowFrameTypes, "spacer");
	FlowContainer_DoLayout(container);
end

function FlowContainer_AddPrimarySpacer(container, spacerSize)
	tinsert(container.flowFrames, spacerSize);
	tinsert(container.flowFrameTypes, "primarySpacer");
	FlowContainer_DoLayout(container);
end

function FlowContainer_BeginAtomicAdd(container)
	tinsert(container.flowFrames, "beginatomic");
	tinsert(container.flowFrameTypes, "beginatomic");
	FlowContainer_DoLayout(container);
end

function FlowContainer_EndAtomicAdd(container)
	tinsert(container.flowFrames, "endatomic");
	tinsert(container.flowFrameTypes, "endatomic");
	FlowContainer_DoLayout(container);
end

function FlowContainer_RemoveObject(container, object)
	assert(type(object) == "table");	--For now, Remove can't be used with non-widgets.
	for i=1, #container.flowFrames do	--Used instead of tRemoveItem to eliminate dependencies.
		if ( container.flowFrames[i] == object ) then
			tremove(container.flowFrames, i);
			tremove(container.flowFrameTypes, i);
			break;
		end
	end
	FlowContainer_DoLayout(container);
end

function FlowContainer_RemoveAllObjects(container)
	container.flowFrames = {};
	container.flowFrameTypes = {};
end

function FlowContainer_GetUsedBounds(container)	--Return x, y
	if ( container.flowOrientation == "horizontal" ) then
		return container.flowMaxSecondaryUsed, container.flowMaxPrimaryUsed;
	else
		return container.flowMaxPrimaryUsed, container.flowMaxSecondaryUsed;
	end
end

function FlowContainer_SetStartingOffset(container, xOffset, yOffset)
	if ( container.flowOrientation == "horizontal" ) then
		container.startingSecondaryOffset = xOffset;
		container.startingPrimaryOffset = -yOffset;
	else
		container.startingSecondaryOffset = -yOffset;
		container.startingPrimaryOffset = xOffset;
	end
end

local function isFrameTypeExemptFromFlowCount(frameType)
	return frameType == "flagged" or frameType == "target";
end

local function GetStartingPrimaryOffset(container)
	return (container.startingPrimaryOffset or 0);
end

local function GetStartingSecondaryOffset(container)
	return (container.startingSecondaryOffset or 0);
end

--:GetWidth() and :GetHeight() are used in this function. --meta-comment: Comment added in case anyone ever searches all files for these.
function FlowContainer_DoLayout(container)
	if ( container.flowPauseUpdates ) then
		return;
	end

	local primaryDirection, secondaryDirection;
	local primarySpacing, secondarySpacing;
	if ( container.flowOrientation == "horizontal" ) then
		primaryDirection = "GetWidth";
		secondaryDirection = "GetHeight";
		primarySpacing = container.flowHorizontalSpacing or 0;
		secondarySpacing = container.flowVerticalSpacing or 0;
	else
		primaryDirection = "GetHeight";
		secondaryDirection = "GetWidth";
		primarySpacing = container.flowVerticalSpacing or 0;
		secondarySpacing = container.flowHorizontalSpacing or 0;
	end

	--To make things easier to understand, I'll comment this as if it was horizontal. To see the vertical comments, just turn your head 90 degrees.
	local currentSecondaryLine, currentPrimaryLine = 1, 1;
	local currentSecondaryOffset, currentPrimaryOffset = GetStartingSecondaryOffset(container), GetStartingPrimaryOffset(container);
	local lineMaxSize = 0;
	local maxSecondaryOffset = 0;
	local atomicAddStart = nil;
	local atomicAtBeginning = nil;
	local i = 1;
	local targetVerticalOffset = nil;
	local lastObject = nil;
	local lastObjectType = nil;
	while ( i <= #container.flowFrames ) do
		local object = container.flowFrames[i];
		local objectType = container.flowFrameTypes[i];
		local doContinue = false;

		--If it doesn't fit on the current row, move to the next.
		if ( objectType == "linebreak" or	--Force a new line
			objectType == "object" and	--Make sure this is an actual object before checking further.
				(object.isFlowGroup or -- Always break if object is a group
				(lastObject and lastObjectType == "object" and lastObject.isFlowGroup) or -- Always break if the last object was a group
				(container.flowMaxPerLine and currentPrimaryLine > container.flowMaxPerLine) or	--We went past the max number of columns
					currentSecondaryOffset + object[primaryDirection](object) > container[primaryDirection](container)) ) then	--We went past the max pixel width.

				if ( not (atomicAddStart and atomicAtBeginning) ) then	--If we're in an atomic add and we started at the beginning of the line, wrapping won't help us
					currentSecondaryOffset = GetStartingSecondaryOffset(container);	--Move back all the way to the left
					currentPrimaryLine = 1;	--Reset column count
					currentPrimaryOffset = currentPrimaryOffset + lineMaxSize + secondarySpacing;	--Move down by the size of the biggest object in the last row
					currentSecondaryLine = currentSecondaryLine + 1;	--Move to the next row.
					lineMaxSize = 0;
					if ( atomicAddStart ) then
						--We wrapped around. So we want to move back to the first item in the atomic add and continue from the position we're leaving off (the new line).
						i = atomicAddStart;
						atomicAtBeginning = true;
						doContinue = true;
					end
				end
		end

		if ( not doContinue ) then
			if ( objectType == "object" ) then
				--Did we completely run out of room? Assert for now. --Scratch that, we're just going to keep growing. When we have time, we'll probably want a "didn't fit" callback.
				--assert(currentPrimaryOffset + object[secondaryDirection](object) < container[secondaryDirection](container));

				--Add it.
				object:ClearAllPoints();
				if container.flowOrientation == "horizontal" then
					object:SetPoint("TOPLEFT", container, "TOPLEFT", currentSecondaryOffset, -currentPrimaryOffset - (targetVerticalOffset or 0));

					if object.frameType == "target" and not targetVerticalOffset then
						targetVerticalOffset = object[secondaryDirection](object);
					else
						targetVerticalOffset = nil;
					end
				else
					object:SetPoint("TOPLEFT", container, "TOPLEFT", currentPrimaryOffset, -currentSecondaryOffset);
				end

				if not targetVerticalOffset then
					currentSecondaryOffset = currentSecondaryOffset + object[primaryDirection](object) + primarySpacing;
				end

				if ( not atomicAddStart ) then	--If we're in the middle of an atomic add, we'll save off the last part when we finish the add.
					maxSecondaryOffset = max(maxSecondaryOffset, currentSecondaryOffset);
				end

				if not isFrameTypeExemptFromFlowCount(object.frameType) then
					currentPrimaryLine = currentPrimaryLine + 1;
				end

				lineMaxSize = max(lineMaxSize, object[secondaryDirection](object));
			elseif ( objectType == "spacer" ) then
				currentSecondaryOffset = currentSecondaryOffset + object;
			elseif ( objectType == "primarySpacer" ) then
				currentPrimaryOffset = currentPrimaryOffset + object;
			elseif ( objectType == "beginatomic" ) then
				if ( currentSecondaryOffset == 0 ) then
					atomicAtBeginning = true;		--If we're already at the top, we don't want to move anything to the next row. (There's no way it would help.)
				end
				atomicAddStart = i + 1;
			elseif ( objectType == "endatomic" ) then
				maxSecondaryOffset = max(maxSecondaryOffset, currentSecondaryOffset);	--We weren't updating the max offset while in an atomic add, so we have to do it now.
				atomicAddStart = nil;
				atomicAtBeginning = nil;
			end

			i = i + 1;
		end

		lastObject = object;
		lastObjectType = objectType;
	end

	--Save off how much we actually used.
	container.flowMaxPrimaryUsed = currentPrimaryOffset + lineMaxSize;
	container.flowMaxSecondaryUsed = maxSecondaryOffset;
end
