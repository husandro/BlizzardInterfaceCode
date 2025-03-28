function AuctionHouseFavoriteContextMenu(frame, itemKey)
	MenuUtil.CreateContextMenu(frame, function(owner, rootDescription)
		rootDescription:SetTag("MENU_AUCTION_HOUSE_FAVORITE");

		local isFavorite = C_AuctionHouse.IsFavoriteItem(itemKey);
	
		local function CanChangeFavoriteState()
			return C_AuctionHouse.FavoritesAreAvailable() and (isFavorite or not C_AuctionHouse.HasMaxFavorites());
		end
	
		local text = isFavorite and AUCTION_HOUSE_DROPDOWN_REMOVE_FAVORITE or AUCTION_HOUSE_DROPDOWN_SET_FAVORITE;
		local buttonDesc = rootDescription:CreateButton(text, function()
			if CanChangeFavoriteState() then
				C_AuctionHouse.SetFavoriteItem(itemKey, not isFavorite);
			end
		end);
	
		buttonDesc:SetEnabled(CanChangeFavoriteState);
	end);
end


AuctionHouseBackgroundMixin = {};

function AuctionHouseBackgroundMixin:OnLoad()
	local xOffset = self.backgroundXOffset or 0;
	local yOffset = self.backgroundYOffset or 0;
	self.Background:SetAtlas(self.backgroundAtlas, true);
	self.Background:SetPoint("TOPLEFT", xOffset + 3, yOffset - 3);

	self.NineSlice:ClearAllPoints();
	self.NineSlice:SetPoint("TOPLEFT", xOffset, yOffset);
	self.NineSlice:SetPoint("BOTTOMRIGHT");
end


AuctionHouseItemDisplayMixin = {};

function AuctionHouseItemDisplayMixin:OnLoad()
	AuctionHouseBackgroundMixin.OnLoad(self);

	self.ItemButton:SetPoint("LEFT", self.itemButtonXOffset or 0, self.itemButtonYOffset or 0);
end

function AuctionHouseItemDisplayMixin:SetItemCountFunction(getItemCount)
	self.getItemCount = getItemCount;
end

function AuctionHouseItemDisplayMixin:SetItemValidationFunction(validationFunc)
	self.itemValidationFunc = validationFunc;
end

function AuctionHouseItemDisplayMixin:OnEvent(event, ...)
	if event == "GET_ITEM_INFO_RECEIVED" then
		if self.pendingInfo.itemKey then
			self:SetItemKey(self.pendingInfo.itemKey);
		elseif self.pendingInfo.itemLocation then
			self:SetItemLocation(self.pendingInfo.itemLocation);
		else
			self:SetItemInternal(self.pendingInfo.item);
		end
	elseif event == "ITEM_KEY_ITEM_INFO_RECEIVED" then
		local itemID = ...;
		if self.pendingItemKey and self.pendingItemKey.itemID == itemID then
			self:SetItemKey(self.pendingItemKey);
		end
	end
end

-- Set and cleared dynamically in OnEnter and OnLeave
function AuctionHouseItemDisplayMixin:OnUpdate()
	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function AuctionHouseItemDisplayMixin:OnEnter()
	self:SetScript("OnUpdate", AuctionHouseItemDisplayMixin.OnUpdate);

	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	end

	if self:IsPet() then
		if self.itemKey then
			local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(self.itemKey);
			if itemKeyInfo and itemKeyInfo.battlePetLink then
				GameTooltip:SetOwner(self.ItemButton, "ANCHOR_RIGHT");
				BattlePetToolTip_ShowLink(itemKeyInfo.battlePetLink);
				AuctionHouseUtil.AppendBattlePetVariationLines(BattlePetTooltip);
			else
				BattlePetTooltip:Hide();
				GameTooltip:Hide();
			end
		else
			local itemLocation = self:GetItemLocation();
			if itemLocation then
				local bagID, slotIndex = itemLocation:GetBagAndSlot();
				if bagID and slotIndex then
					GameTooltip:SetOwner(self.ItemButton, "ANCHOR_RIGHT");
					GameTooltip:SetBagItem(bagID, slotIndex);
				end
			end
		end
	else
		BattlePetTooltip:Hide();

		local itemLocation = self:GetItemLocation();
		if itemLocation then
			GameTooltip:SetOwner(self.ItemButton, "ANCHOR_RIGHT");
			GameTooltip:SetHyperlink(C_Item.GetItemLink(itemLocation));
			GameTooltip:Show();
		else
			local itemKey = self:GetItemKey();
			if itemKey then
				GameTooltip:SetOwner(self.ItemButton, "ANCHOR_RIGHT");
				GameTooltip:SetItemKey(itemKey.itemID, itemKey.itemLevel, itemKey.itemSuffix, C_AuctionHouse.GetItemKeyRequiredLevel(itemKey));
				GameTooltip:Show();
			else
				local itemLink = self:GetItemLink();
				if itemLink then
					GameTooltip:SetOwner(self.ItemButton, "ANCHOR_RIGHT");
					GameTooltip:SetHyperlink(itemLink);
					GameTooltip:Show();
				end
			end
		end

		self.ItemButton.UpdateTooltip = self.ItemButton:GetScript("OnEnter");
	end
end

function AuctionHouseItemDisplayMixin:OnLeave()
	self:SetScript("OnUpdate", nil);

	ResetCursor();
	GameTooltip:Hide();

	if(BattlePetTooltip) then
		BattlePetTooltip:Hide();
	end
end

function AuctionHouseItemDisplayMixin:OnClick(button)
	local itemKey = self:GetItemKey();
	if itemKey then
		if button == "RightButton" then
			AuctionHouseFavoriteContextMenu(self, itemKey);
		elseif button == "LeftButton" then
			if IsModifiedClick("DRESSUP") then
				local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey);
				if itemKeyInfo and itemKeyInfo.battlePetLink then
					DressUpBattlePetLink(itemKeyInfo.battlePetLink);
				else
					if itemKeyInfo.appearanceLink then
						local _, _, hyperlinkString = ExtractHyperlinkString(itemKeyInfo.appearanceLink);
						DressUpTransmogLink(hyperlinkString);
					else
						DressUpLink(self:GetItemLink());
					end
				end
			elseif IsModifiedClick("CHATLINK") then
				local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey);
				if itemKeyInfo and itemKeyInfo.battlePetLink then
					ChatEdit_InsertLink(itemKeyInfo.battlePetLink);
				else
					ChatEdit_InsertLink(self:GetItemLink());
				end
			end
		end
	end
end

function AuctionHouseItemDisplayMixin:Reset()
	SetItemButtonCount(self.ItemButton, nil);
	SetItemButtonTexture(self.ItemButton, nil);
	SetItemButtonQuality(self.ItemButton, nil, nil);
	self.Name:SetText("");

	self.itemKey = nil;
	self.itemLocation = nil;
	self.itemLink = nil;
end

function AuctionHouseItemDisplayMixin:SetAuctionHouseFrame(auctionHouseFrame)
	self.auctionHouseFrame = auctionHouseFrame;
end

function AuctionHouseItemDisplayMixin:SetItemLevelShown(shown)
	self.itemLevelShown = shown;
end

function AuctionHouseItemDisplayMixin:SetItemSource(itemKey, itemLocation)
	self.itemKey = itemKey;
	self.itemLocation = itemLocation;
end

function AuctionHouseItemDisplayMixin:GetItemSource()
	return self.itemKey, self.itemLocation;
end

function AuctionHouseItemDisplayMixin:SetItemKey(itemKey)
	if itemKey == nil then
		self:SetItemInternal(nil);
		return true;
	end

	local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey);
	if not itemKeyInfo then
		self.pendingItemKey = itemKey;
		self:RegisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED");
		return false;
	end

	if self.pendingItemKey ~= nil then
		self:UnregisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED");
	end

	self.pendingItemKey = nil;

	self:SetItemSource(itemKey, nil);

	local successful = self:SetItemInternal(itemKey.itemID);
	if successful then
		self.Name:SetText(AuctionHouseUtil.GetItemDisplayTextFromItemKey(itemKey, itemKeyInfo));
		SetItemButtonTexture(self.ItemButton, itemKeyInfo.iconFileID);
		SetItemButtonQuality(self.ItemButton, itemKeyInfo.quality);
		
		self.FavoriteButton:SetItemKey(itemKey);
	end

	return successful;
end

function AuctionHouseItemDisplayMixin:SetItemLocation(itemLocation)
	local originalItemKey, originalItemLocation = self:GetItemSource();
	self:SetItemSource(nil, itemLocation);

	if itemLocation == nil or not C_Item.DoesItemExist(itemLocation) then
		self:SetItemInternal(nil);

		local successful = (itemLocation == nil);
		if successful then
			return true;
		end

		self:SetItemSource(originalItemKey, originalItemLocation);
		return false;
	end

	if self:SetItemInternal(C_Item.GetItemLink(itemLocation)) then
		return true;
	end

	self:SetItemSource(originalItemKey, originalItemLocation);
	return false;
end

-- item must be an itemID, item link or an item name.
function AuctionHouseItemDisplayMixin:SetItem(item)
	self:SetItemSource(nil, nil);
	return self:SetItemInternal(item);
end

function AuctionHouseItemDisplayMixin:SetItemInternal(item)
	if self.itemValidationFunc and not self.itemValidationFunc(self) then
		return false;
	end

	self.item = item;

	if not item then
		self:Reset();
		return true;
	end

	local itemName, itemLink, itemQuality, itemLevel, itemIcon = self:GetItemInfo();

	self.itemLink = itemLink;
	if self.itemLink == nil then
		self.pendingInfo = {item = self.item, itemKey = self.itemKey, itemLocation = self.itemLocation};
		self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
		self:Reset();
		return true;
	end

	self.pendingItem = nil;
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");

	local isPet = self:IsPet();

	local itemCount = self.getItemCount and self.getItemCount(self) or nil;
	SetItemButtonCount(self.ItemButton, itemCount);
	SetItemButtonTexture(self.ItemButton, itemIcon);

	local itemLinkForQuality = not isPet and itemLink or nil;
	SetItemButtonQuality(self.ItemButton, itemQuality, itemLinkForQuality);

	local displayText = self:GetItemDisplayText(itemName, itemLevel, isPet);

	local nameText = displayText;
	local colorData = ColorManager.GetColorDataForItemQuality(itemQuality);
	if colorData then
		nameText = colorData.color:WrapTextInColorCode(displayText);
	end

	self.Name:SetText(nameText);

	self.ItemButton:UnlockHighlight();

	return true;
end

function AuctionHouseItemDisplayMixin:IsPet()
	if self.itemKey then
		local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(self.itemKey);
		return itemKeyInfo and itemKeyInfo.isPet;
	end

	local itemLink = self:GetItemLink();
	if itemLink == nil then
		return false;
	end

	return LinkUtil.IsLinkType(itemLink, "battlepet");
end

function AuctionHouseItemDisplayMixin:GetItemDisplayText(itemName, itemLevel, isPet)
	if isPet then
		return itemName;
	end

	if (C_TradeSkillUI.GetItemReagentQualityByItemInfo) then
		local craftingQuality = C_TradeSkillUI.GetItemReagentQualityByItemInfo(self.item);
	else
		local craftingQuality = nil;
	end
	
	return AuctionHouseUtil.GetItemDisplayText(itemName, self.itemLevelShown and itemLevel or nil, craftingQuality);
end

function AuctionHouseItemDisplayMixin:GetItemInfo()
	local itemLocation = self:GetItemLocation();
	if itemLocation then
		local itemName = C_Item.GetItemName(itemLocation);
		local itemLink = C_Item.GetItemLink(itemLocation);
		local itemQuality = C_Item.GetItemQuality(itemLocation);
		local itemLevel = C_Item.GetCurrentItemLevel(itemLocation);
		local itemIcon = C_Item.GetItemIcon(itemLocation);
		return itemName, itemLink, itemQuality, itemLevel, itemIcon;
	else
		local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = C_Item.GetItemInfo(self:GetItem());
		return itemName, itemLink, itemQuality, itemLevel, itemIcon;
	end
end

function AuctionHouseItemDisplayMixin:GetItemID()
	local itemLink = self:GetItemLink();
	if not itemLink then
		return nil;
	end

	-- Storing in a local for clarity, and to avoid additional returns.
	local itemID = C_Item.GetItemInfoInstant(itemLink);
	return itemID;
end

function AuctionHouseItemDisplayMixin:GetItem()
	return self.item;
end

function AuctionHouseItemDisplayMixin:GetItemLink()
	return self.itemLink;
end

function AuctionHouseItemDisplayMixin:GetItemKey()
	if self.itemKey then
		return self.itemKey;
	elseif self.itemLocation then
		return C_AuctionHouse.GetItemKeyFromItem(self.itemLocation);
	else
		local itemID = self:GetItemID();
		if itemID then
			return C_AuctionHouse.MakeItemKey(itemID);
		end
	end

	return nil;
end

function AuctionHouseItemDisplayMixin:GetItemLocation()
	return self.itemLocation;
end

function AuctionHouseItemDisplayMixin:GetItemCount()
	return GetItemButtonCount(self.ItemButton);
end

function AuctionHouseItemDisplayMixin:SetHighlightLocked(locked)
	if locked then
		self.ItemButton:LockHighlight();
	else
		self.ItemButton:UnlockHighlight();
	end
end


AuctionHouseItemDisplayItemButtonMixin = {};

function AuctionHouseItemDisplayItemButtonMixin:OnLoad()
	self:ClearHighlightTexture();
end

function AuctionHouseItemDisplayItemButtonMixin:OnClick(...)
	self:GetParent():OnClick(...);
end

function AuctionHouseItemDisplayItemButtonMixin:OnEnter()
	self:GetParent():OnEnter();
end

function AuctionHouseItemDisplayItemButtonMixin:OnLeave()
	self:GetParent():OnLeave();
end


AuctionHouseInteractableItemDisplayItemButtonMixin = CreateFromMixins(AuctionHouseItemDisplayItemButtonMixin);

function AuctionHouseInteractableItemDisplayItemButtonMixin:OnLoad()
	-- Intentional override.
end

function AuctionHouseInteractableItemDisplayItemButtonMixin:OnEnter()
	self:GetParent():OnEnter();
end

function AuctionHouseInteractableItemDisplayItemButtonMixin:OnLeave()
	self:GetParent():OnLeave();
end

function AuctionHouseInteractableItemDisplayItemButtonMixin:Init()
	self:RegisterForDrag("LeftButton");
end

function AuctionHouseInteractableItemDisplayItemButtonMixin:GetItemLocation()
	local itemDisplay = self:GetParent();
	return itemDisplay:GetItemLocation();
end

function AuctionHouseInteractableItemDisplayItemButtonMixin:SetItemLocation(itemLocation)
	local itemDisplay = self:GetParent();
	return itemDisplay:SetItemLocation(itemLocation);
end

function AuctionHouseInteractableItemDisplayItemButtonMixin:SwitchItemWithCursor()
	local itemDisplay = self:GetParent();
	itemDisplay:SwitchItemWithCursor();
end

function AuctionHouseInteractableItemDisplayItemButtonMixin:OnClick(button, ...)
	if button == "RightButton" then
		self:SetItemLocation(nil);
	else
		self:GetParent():OnClick(button, ...);
	end
end

function AuctionHouseInteractableItemDisplayItemButtonMixin:OnDragStart()
	local currentItemLocation = self:GetItemLocation();
	self:SetItemLocation(nil);
	if currentItemLocation ~= nil then
		ItemUtil.PickupBagItem(currentItemLocation);
	end
end

function AuctionHouseInteractableItemDisplayItemButtonMixin:OnReceiveDrag()
	self:SwitchItemWithCursor();
end


AuctionHouseInteractableItemDisplayMixin = CreateFromMixins(AuctionHouseItemDisplayMixin);

local InteractableItemButtonScripts = {
	"OnClick",
	"OnDragStart",
	"OnReceiveDrag",
};

function AuctionHouseInteractableItemDisplayMixin:OnLoad()
	AuctionHouseItemDisplayMixin.OnLoad(self);

	self.ItemButton:Init();
	for i, scriptName in ipairs(InteractableItemButtonScripts) do
		self.ItemButton:SetScript(scriptName, self.ItemButton[scriptName]);
	end
end

function AuctionHouseInteractableItemDisplayMixin:OnEnter()
	AuctionHouseItemDisplayMixin.OnEnter(self);

	local item = C_Cursor.GetCursorItem();
	if item then
		self:SetHighlightLocked(true);
	end
end

function AuctionHouseInteractableItemDisplayMixin:OnLeave()
	AuctionHouseItemDisplayMixin.OnLeave(self);

	self:SetHighlightLocked(false);
end

function AuctionHouseInteractableItemDisplayMixin:OnClick(button, ...)
	AuctionHouseItemDisplayMixin.OnClick(self, button, ...);

	if button == "LeftButton" and not IsModifiedClick("DRESSUP") then
		self:SwitchItemWithCursor();
		if self:GetItemLocation() or self:GetItemLink() then
			self:OnEnter();
		else
			self:OnLeave();
		end
	end
end

function AuctionHouseInteractableItemDisplayMixin:OnReceiveDrag()
	self:OnClick("LeftButton");

	if self:GetItemLocation() or self:GetItemLink() then
		self:OnEnter();
	end
end

function AuctionHouseInteractableItemDisplayMixin:SetOnItemChangedCallback(callback)
	self.onItemChangedCallback = callback;
end

function AuctionHouseInteractableItemDisplayMixin:SetItemLocation(itemLocation, skipCallback)
	local currentItemLocation = self:GetItemLocation();

	local successful = AuctionHouseItemDisplayMixin.SetItemLocation(self, itemLocation);
	if not successful then
		return false;
	end

	if currentItemLocation and C_Item.DoesItemExist(currentItemLocation) then
		C_Item.UnlockItem(currentItemLocation);
	end

	if itemLocation then
		if C_Item.DoesItemExist(itemLocation) then
			C_Item.LockItem(itemLocation);
		end
	end

	if not skipCallback and self.onItemChangedCallback then
		self.onItemChangedCallback(itemLocation);
	end

	return true;
end

function AuctionHouseInteractableItemDisplayMixin:SwitchItemWithCursor(skipCallback)
	local cursorItem = C_Cursor.GetCursorItem();
	local currentItemLocation = self:GetItemLocation();
	if (cursorItem or currentItemLocation) and (self:SetItemLocation(cursorItem, skipCallback) or cursorItem == nil) then
		ClearCursor();

		ItemUtil.PickupBagItem(currentItemLocation or cursorItem);
	end
end

function AuctionHouseInteractableItemDisplayMixin:GetItemDisplayText(itemName, itemLevel, isPet)
	if isPet then
		return AuctionHouseItemDisplayMixin.GetItemDisplayText(self, itemName, itemLevel, isPet);
	end

	-- Never display crafting quality in the item text since it will display as an overlay on top of the icon.
	local craftingQuality = nil;
	return AuctionHouseUtil.GetItemDisplayText(itemName, self.itemLevelShown and itemLevel or nil, craftingQuality);
end


AuctionHouseQuantityInputBoxMixin = {};

function AuctionHouseQuantityInputBoxMixin:OnLoad()
	self:SetFontObject("PriceFont");
end

function AuctionHouseQuantityInputBoxMixin:SetInputChangedCallback(callback)
	self.inputChangedCallback = callback;
end

function AuctionHouseQuantityInputBoxMixin:GetInputChangedCallback()
	return self.inputChangedCallback;
end

function AuctionHouseQuantityInputBoxMixin:OnTextChanged(userInput)
	if self:GetNumber() == 0 then
		self:SetText("");
	end

	if userInput and self.inputChangedCallback then
		self.inputChangedCallback();
	end
end

function AuctionHouseQuantityInputBoxMixin:Reset()
	self:SetNumber(1);
end


AuctionHousePriceDisplayFrameMixin = {};

function AuctionHousePriceDisplayFrameMixin:OnLoad()
	self.Label:SetText(self.labelText or "");
end

function AuctionHousePriceDisplayFrameMixin:SetAmount(amount)
	self.MoneyDisplayFrame:SetAmount(amount);
end

function AuctionHousePriceDisplayFrameMixin:GetAmount()
	return self.MoneyDisplayFrame:GetAmount();
end


AuctionHouseRefreshFrameMixin = {};

function AuctionHouseRefreshFrameMixin:SetQuantity(totalQuantity)
	self.RefreshButton:SetEnabledState(true);

	local hasResults = totalQuantity ~= 0;
	self.TotalQuantity:SetText(hasResults and AUCTION_HOUSE_QUANTITY_AVAILABLE_FORMAT:format(totalQuantity) or "");
end

function AuctionHouseRefreshFrameMixin:Deactivate()
	self.RefreshButton:SetEnabledState(false);
	self.TotalQuantity:SetText("");
end

function AuctionHouseRefreshFrameMixin:SetRefreshCallback(refreshCallback)
	self.RefreshButton:SetOnClickHandler(refreshCallback);
end


AuctionHouseRefreshButtonMixin = {};

function AuctionHouseRefreshButtonMixin:OnLoad()
	SquareIconButtonMixin.OnLoad(self);

	self:SetTooltipInfo(AUCTION_HOUSE_REFRESH_BUTTON_TOOLTIP);
end


AuctionHouseBidFrameMixin = {};

function AuctionHouseBidFrameMixin:SetBidCallback(bidCallback)
	self.bidCallback = bidCallback;
end

function AuctionHouseBidFrameMixin:OnLoad()
	local displayCopper = C_AuctionHouse.SupportsCopperValues();
	MoneyInputFrame_SetCopperShown(self.BidAmount, displayCopper);
end

function AuctionHouseBidFrameMixin:SetPrice(minBid, isOwnerItem, isPlayerHighBid)
	MoneyInputFrame_SetCopper(self.BidAmount, minBid);

	if isPlayerHighBid or minBid == 0 then
		MoneyInputFrame_SetEnabled(self.BidAmount, false);
		self.BidButton:SetDisableTooltip("");
	elseif minBid > GetMoney() then
		MoneyInputFrame_SetEnabled(self.BidAmount, false);
		self.BidButton:SetDisableTooltip(AUCTION_HOUSE_TOOLTIP_TITLE_NOT_ENOUGH_MONEY);
	elseif isOwnerItem then
		MoneyInputFrame_SetEnabled(self.BidAmount, false);
		self.BidButton:SetDisableTooltip(AUCTION_HOUSE_TOOLTIP_TITLE_OWN_AUCTION);
	else
		MoneyInputFrame_SetEnabled(self.BidAmount, true);
		self.BidButton:SetDisableTooltip(nil);
	end
end

function AuctionHouseBidFrameMixin:GetPrice()
	return MoneyInputFrame_GetCopper(self.BidAmount);
end

function AuctionHouseBidFrameMixin:PlaceBid()
	if self.bidCallback then
		self.bidCallback();
	end
end


AuctionHouseBuyoutFrameMixin = {};

function AuctionHouseBuyoutFrameMixin:SetBuyoutCallback(buyoutCallback)
	self.buyoutCallback = buyoutCallback;
end

function AuctionHouseBuyoutFrameMixin:SetPrice(price, isOwnerItem)
	self.price = price;

	if isOwnerItem then
		self.BuyoutButton:SetDisableTooltip(AUCTION_HOUSE_TOOLTIP_TITLE_OWN_AUCTION);
	elseif price > GetMoney() then
		self.BuyoutButton:SetDisableTooltip(AUCTION_HOUSE_TOOLTIP_TITLE_NOT_ENOUGH_MONEY);
	elseif price <= 0 then
		self.BuyoutButton:SetDisableTooltip("");
	else
		self.BuyoutButton:SetDisableTooltip(nil);
	end
end

function AuctionHouseBuyoutFrameMixin:GetPrice()
	return self.price;
end

function AuctionHouseBuyoutFrameMixin:BuyoutItem()
	if self.buyoutCallback then
		self.buyoutCallback();
	end
end


AuctionHouseBidButtonMixin = {};

function AuctionHouseBidButtonMixin:OnClick()
	self:GetParent():PlaceBid();
end


AuctionHouseBuyoutButtonMixin = {};

function AuctionHouseBuyoutButtonMixin:OnClick()
	self:GetParent():BuyoutItem();
end

AuctionHouseFavoriteButtonBaseMixin = {};

function AuctionHouseFavoriteButtonBaseMixin:OnEnter()
	if not self:IsInteractionAvailable() then
		self:ShowMaxedFavoritesTooltip();
	end
end

function AuctionHouseFavoriteButtonBaseMixin:ShowMaxedFavoritesTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddErrorLine(GameTooltip, AUCTION_HOUSE_FAVORITES_MAXED_TOOLTIP);
	GameTooltip:Show();
end

function AuctionHouseFavoriteButtonBaseMixin:OnLeave()
	GameTooltip_Hide();
end

function AuctionHouseFavoriteButtonBaseMixin:OnClick()
	if not self:IsInteractionAvailable() then
		return;
	end
	
	local setToFavorite = not self:IsFavorite();
	C_AuctionHouse.SetFavoriteItem(self.itemKey, setToFavorite);
	self:UpdateFavoriteState();
end

function AuctionHouseFavoriteButtonBaseMixin:IsInteractionAvailable()
	return C_AuctionHouse.FavoritesAreAvailable() and (self:IsFavorite() or not C_AuctionHouse.HasMaxFavorites());
end

function AuctionHouseFavoriteButtonBaseMixin:SetItemKey(itemKey)
	self.itemKey = itemKey;
	self:UpdateFavoriteState();
end

function AuctionHouseFavoriteButtonBaseMixin:UpdateFavoriteState()
	local isFavorite = self:IsFavorite();
	local currAtlas = isFavorite and "auctionhouse-icon-favorite" or "auctionhouse-icon-favorite-off";
	self.NormalTexture:SetAtlas(currAtlas);

	self.HighlightTexture:SetAtlas(currAtlas);
	self.HighlightTexture:SetAlpha(isFavorite and 0.2 or 0.4);
end

function AuctionHouseFavoriteButtonBaseMixin:IsFavorite()
	return self.itemKey and C_AuctionHouse.IsFavoriteItem(self.itemKey);
end