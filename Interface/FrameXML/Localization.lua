
-- This is a symbol available for people who need to know the locale (separate from GetLocale())
LOCALE_itIT = true;

function Localize()
	-- Put all locale specific string adjustments here
	PLAYER_LIST_DELIMITER = PLAYER_LIST_DELIMITER.." ";	--Don't ask (bug 158181)
end

function LocalizeFrames()
	-- Put all locale specific UI adjustments here
	SetEuropeanNumbers(true);

	-- Hide billing help option.  If the number of help options changes this will need to change also.
	CATEGORY_TO_NOT_DISPLAY = 9;
	
	UIDropDownMenu_SetWidth(FriendsFriendsFrameDropDown, 136);
	
	BUFF_HORIZ_SPACING = -10;
end
