DigSiteDataProviderMixin = CreateFromMixins(CVarMapCanvasDataProviderMixin);
DigSiteDataProviderMixin:Init("digSites");

function DigSiteDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("DigSitePinTemplate");
end

function DigSiteDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	
	if not self:IsCVarSet() then
		return;
	end

	local mapID = self:GetMap():GetMapID();
	local digSites = C_ResearchInfo.GetDigSitesForMap(mapID);
	for i, digSiteInfo in ipairs(digSites) do
		self:GetMap():AcquirePin("DigSitePinTemplate", digSiteInfo);
	end
end

--[[ Pin ]]--
DigSitePinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DIG_SITE");

function DigSitePinMixin:OnAcquired(...)
	SuperTrackablePoiPinMixin.OnAcquired(self, ...);
end

function DigSitePinMixin:GetSuperTrackData()
	return Enum.SuperTrackingMapPinType.DigSite, self.poiInfo.researchSiteID;
end

function DigSitePinMixin:GetSuperTrackMarkerOffset()
	return -2, 2;
end