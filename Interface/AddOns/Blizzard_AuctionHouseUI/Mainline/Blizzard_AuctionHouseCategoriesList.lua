function AuctionHouseFilterButton_SetUp(button, info)
	local normalText = button.Text;
	local normalTexture = button.NormalTexture;
	local line = button.Lines;

	if ( info.type == "category" ) then
		if (info.isToken) then
			button:SetNormalFontObject(GameFontNormalSmallBattleNetBlueLeft);
		else
			button:SetNormalFontObject(GameFontNormalSmall);
		end

		button.NormalTexture:SetAtlas("auctionhouse-nav-button", false);
		button.NormalTexture:SetSize(136,32);
		button.NormalTexture:ClearAllPoints();
		button.NormalTexture:SetPoint("TOPLEFT", -2, 0);
		button.SelectedTexture:SetAtlas("auctionhouse-nav-button-select", false);
		button.SelectedTexture:SetSize(132,21);
		button.SelectedTexture:ClearAllPoints();
		button.SelectedTexture:SetPoint("LEFT");
		button.HighlightTexture:SetAtlas("auctionhouse-nav-button-highlight", false);
		button.HighlightTexture:SetSize(132,21);
		button.HighlightTexture:ClearAllPoints();
		button.HighlightTexture:SetPoint("LEFT");
		button.HighlightTexture:SetBlendMode("BLEND");
		button:SetText(info.name);
		normalText:SetPoint("LEFT", button, "LEFT", 8, 0);
		normalTexture:SetAlpha(1.0);	
		line:Hide();
	elseif ( info.type == "subCategory" ) then
		button:SetNormalFontObject(GameFontHighlightSmall);
		button.NormalTexture:SetAtlas("auctionhouse-nav-button-secondary", false);
		button.NormalTexture:SetSize(133,32);
		button.NormalTexture:ClearAllPoints();
		button.NormalTexture:SetPoint("TOPLEFT", 1, 0);
		button.SelectedTexture:SetAtlas("auctionhouse-nav-button-secondary-select", false);
		button.SelectedTexture:SetSize(122,21);
		button.SelectedTexture:ClearAllPoints();
		button.SelectedTexture:SetPoint("TOPLEFT", 10, 0);
		button.HighlightTexture:SetAtlas("auctionhouse-nav-button-secondary-highlight", false);
		button.HighlightTexture:SetSize(122,21);
		button.HighlightTexture:ClearAllPoints();
		button.HighlightTexture:SetPoint("TOPLEFT", 10, 0);
		button.HighlightTexture:SetBlendMode("BLEND");
		button:SetText(info.name);
		normalText:SetPoint("LEFT", button, "LEFT", 18, 0);
		normalTexture:SetAlpha(1.0);
		line:Hide();
	elseif ( info.type == "subSubCategory" ) then
		button:SetNormalFontObject(GameFontHighlightSmall);
		button.NormalTexture:ClearAllPoints();
		button.NormalTexture:SetPoint("TOPLEFT", 10, 0);
		button.SelectedTexture:SetAtlas("auctionhouse-ui-row-select", false);
		button.SelectedTexture:SetSize(116,18);
		button.SelectedTexture:ClearAllPoints();
		button.SelectedTexture:SetPoint("TOPRIGHT",0,-2);		
		button.HighlightTexture:SetAtlas("auctionhouse-ui-row-highlight", false);
		button.HighlightTexture:SetSize(116,18);
		button.HighlightTexture:ClearAllPoints();
		button.HighlightTexture:SetPoint("TOPRIGHT",0,-2);
		button.HighlightTexture:SetBlendMode("ADD");
		button:SetText(info.name);
		normalText:SetPoint("LEFT", button, "LEFT", 26, 0);
		normalTexture:SetAlpha(0.0);	
		line:Show();
	end
	button.type = info.type; 

	if ( info.type == "category" ) then
		button.categoryIndex = info.categoryIndex;
	elseif ( info.type == "subCategory" ) then
		button.subCategoryIndex = info.subCategoryIndex;
	elseif ( info.type == "subSubCategory" ) then
		button.subSubCategoryIndex = info.subSubCategoryIndex;
	end
	
	button.SelectedTexture:SetShown(info.selected);
end


