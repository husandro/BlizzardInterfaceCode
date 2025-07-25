-- Provides a basic interface for something that manages the adding, updating, and removing of data like icons, blobs or text to the map canvas
MapCanvasDataProviderMixin = {};

function MapCanvasDataProviderMixin:OnAdded(owningMap)
	-- Optionally override in your mixin, called when this provider is added to a map canvas
	self.owningMap = owningMap;
end

function MapCanvasDataProviderMixin:OnRemoved(owningMap)
	-- Optionally override in your mixin, called when this provider is removed from a map canvas
	assert(owningMap == self.owningMap);
	self.owningMap = nil;

	if self.registeredEvents then
		for event in pairs(self.registeredEvents) do
			owningMap:UnregisterEvent(event);
		end
		self.registeredEvents = nil;
	end
end

function MapCanvasDataProviderMixin:RemoveAllData()
	-- Override in your mixin, this method should remove everything that has been added to the map
end

function MapCanvasDataProviderMixin:RefreshAllData(fromOnShow)
	-- Override in your mixin, this method should assume the map is completely blank, and refresh any data necessary on the map
end

function MapCanvasDataProviderMixin:OnShow()
	-- Override in your mixin, called when the map canvas is shown
end

function MapCanvasDataProviderMixin:OnHide()
	-- Override in your mixin, called when the map canvas is closed
end

function MapCanvasDataProviderMixin:OnMapInsetSizeChanged(mapInsetIndex, expanded)
	-- Optionally override in your mixin, called when a map inset changes sizes
end

function MapCanvasDataProviderMixin:OnMapInsetMouseEnter(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset gains mouse focus
end

function MapCanvasDataProviderMixin:OnMapInsetMouseLeave(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset loses mouse focus
end

function MapCanvasDataProviderMixin:OnCanvasScaleChanged()
	-- Optionally override in your mixin, called when the canvas scale changes
end

function MapCanvasDataProviderMixin:OnCanvasPanChanged()
	-- Optionally override in your mixin, called when the pan location changes
end

function MapCanvasDataProviderMixin:OnCanvasSizeChanged()
	-- Optionally override in your mixin, called when the canvas size changes
end

function MapCanvasDataProviderMixin:OnEvent(event, ...)
	-- Override in your mixin to accept events register via RegisterEvent
end

function MapCanvasDataProviderMixin:OnGlobalAlphaChanged()
	-- Optionally override in your mixin if your data provider obeys global alpha, called when the global alpha changes
end

function MapCanvasDataProviderMixin:GetMap()
	return self.owningMap;
end

function MapCanvasDataProviderMixin:OnMapChanged()
	--  Optionally override in your mixin, called when map ID changes
	self:RefreshAllData();
end

function MapCanvasDataProviderMixin:RegisterEvent(event)
	-- Since data providers aren't frames this provides a similar method of event registration, but always calls self:OnEvent(event, ...)
	if not self.registeredEvents then
		self.registeredEvents = {}
	end
	if not self.registeredEvents[event] then
		self.registeredEvents[event] = true;
		self:GetMap():AddDataProviderEvent(event);
	end
end

function MapCanvasDataProviderMixin:UnregisterEvent(event)
	if self.registeredEvents and self.registeredEvents[event] then
		self.registeredEvents[event] = nil;
		self:GetMap():RemoveDataProviderEvent(event);
	end
end

function MapCanvasDataProviderMixin:SignalEvent(event, ...)
	if self.registeredEvents and self.registeredEvents[event] then
		self:OnEvent(event, ...);
	end
end

function MapCanvasDataProviderMixin:HandleMouseAction(button, action)
	local overriden = self:GetMap():ProcessGlobalPinOverrideMouseHandlers(button, action);
	return not overriden;
end

function MapCanvasDataProviderMixin:PingPin(idKey, id, frameLevelType, numLoops)
	if self.pingPin then
		self.pingPin:Stop();
	end

	local targetPin;
	for pin in self:GetMap():EnumeratePinsByTemplate(self:GetPinTemplate()) do
		if pin[idKey] == id then
			targetPin = pin;
			break;
		end
	end

	if not targetPin then
		return false;
	end

	if not self.pingPin then
		self.pingPin = self:GetMap():AcquirePin("MapPinPingTemplate");
		self.pingPin.dataProvider = self;
		self.pingPin:UseFrameLevelType(frameLevelType);
	end

	self.pingPin:SetNumLoops(numLoops or 1);
	self.pingPin:SetID(idKey, id);
	local x, y = targetPin:GetPosition();
	self.pingPin:PlayAt(x, y);

	return true;
end

function MapCanvasDataProviderMixin:UpdatePing()
	if not self.pingPin or not self.pingPin:IsActive() then
		return;
	end

	local idKey, id = self.pingPin:GetID();
	local targetPin = self:GetPingTargetPin(idKey, id);
	if not targetPin then
		self.pingPin:Stop();
		return;
	end

	local x, y = targetPin:GetPosition();
	self.pingPin:PlayAt(x, y);
end

function MapCanvasDataProviderMixin:GetPingTargetPin(idKey, id)
	for pin in self:GetMap():EnumeratePinsByTemplate(self:GetPinTemplate()) do
		if pin[idKey] == id then
			return pin;
		end
	end
	return nil;
end

-- A base template for data providers that are enabled or disabled with a CVar, e.g. archaeology digsites.
CVarMapCanvasDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function CVarMapCanvasDataProviderMixin:Init(cvar)
	self.cvar = cvar;
end

function CVarMapCanvasDataProviderMixin:IsCVarSet()
	return GetCVarBool(self.cvar);
end

function CVarMapCanvasDataProviderMixin:OnShow()
	self:RegisterEvent("CVAR_UPDATE");
end

function CVarMapCanvasDataProviderMixin:OnHide()
	self:UnregisterEvent("CVAR_UPDATE");
end

function CVarMapCanvasDataProviderMixin:OnEvent(event, ...)
	if event == "CVAR_UPDATE" then
		local eventName, value = ...;
		if eventName == self.cvar then
			self:RefreshAllData();
		end
	end
end

-- Provides a basic interface for something that is visible on the map canvas, like icons, blobs or text
MapCanvasPinMixin = CreateFromMixins(TaggableObjectMixin);

function MapCanvasPinMixin:OnLoad()
	-- Override in your mixin, called when this pin is created
end

function MapCanvasPinMixin:OnAcquired(...) -- the arguments here are anything that are passed into AcquirePin after the pinTemplate
	-- Override in your mixin, called when this pin is being acquired by a data provider but before its added to the map
end

function MapCanvasPinMixin:OnReleased()
	-- Make sure to call the base if you override in your mixin
	-- Called when this pin is being released by a data provider and is no longer on the map
	if self.widgetContainer then
		self.widgetContainer:UnregisterForWidgetSet();
	end
end

function MapCanvasPinMixin:AddIconWidgets()
	if not self.iconWidgetSet then
		if self.widgetContainer then
			self.widgetContainer:UnregisterForWidgetSet();
		end
		return;
	end

	if not self.widgetContainer then
		self.widgetContainer = CreateFrame("FRAME", nil, self, "UIWidgetContainerTemplate");
		self.widgetContainer.forceWidgetSetLayoutDirection = Enum.UIWidgetSetLayoutDirection.Overlap;
		self.widgetContainer:SetPoint("CENTER", self, "CENTER", 0, 0);

		if not self.widgetAnimationTexture then
			self.widgetAnimationTexture = self.Texture;
		end
	end

	self.widgetContainer:RegisterForWidgetSet(self.iconWidgetSet);
end

function MapCanvasPinMixin:OnClick(...)
	local map = self:GetMap();
	if map and map:ProcessGlobalPinMouseActionHandlers(MapCanvasMixin.MouseAction.Click, ...) then
		return;
	end

	if self.OnMouseClickAction then
		self:OnMouseClickAction(...);
	end
end

function MapCanvasPinMixin:DisableInheritedMotionScriptsWarning()
	-- Override in your mixin to disable warnings (for use if you're inheriting from a template that has OnEnter/OnLeave defined).
	-- Make sure you call the appropriate OnEnter/OnLeave inside OnMouseEnter/OnMouseLeave.

	return false;
end

function MapCanvasPinMixin:OnMouseEnter()
	-- Override in your mixin, called when the mouse enters this pin
end

function MapCanvasPinMixin:OnMouseLeave()
	-- Override in your mixin, called when the mouse leaves this pin
end

function MapCanvasPinMixin:OnMouseDown(...)
	local map = self:GetMap();
	if map and map:ProcessGlobalPinMouseActionHandlers(MapCanvasMixin.MouseAction.Down, ...) then
		return;
	elseif not map then
		self:ReportPinError("Invalid map for pin (level [%s]) where last map used was [%s]", tostring(self:GetFrameLevelType()), tostring(self:GetLastDisplayMap()));
	end

	if self.OnMouseDownAction then
		self:OnMouseDownAction(...);
	end
end

function MapCanvasPinMixin:OnMouseUp(...)
	local map = self:GetMap();
	if map and map:ProcessGlobalPinMouseActionHandlers(MapCanvasMixin.MouseAction.Up, ...) then
		return;
	end

	if self.OnMouseUpAction then
		self:OnMouseUpAction(...);
	end
end

function MapCanvasPinMixin:ShouldMouseButtonBePassthrough(button)
	return button == "RightButton"; -- override if necessary
end

function MapCanvasPinMixin:CheckMouseButtonPassthrough(...)
	-- Pins get reused, so this needs to be updated each time a pin is acquired.
	self:SetPassThroughButtons(); -- Clear existing passthrough buttons

	local passthroughButtons = {};
	for i = 1, select("#", ...) do
		local button = select(i, ...);
		if self:ShouldMouseButtonBePassthrough(button) then
			table.insert(passthroughButtons, button);
		end
	end

	self:SetPassThroughButtons(unpack(passthroughButtons));
end

function MapCanvasPinMixin:OnMapInsetSizeChanged(mapInsetIndex, expanded)
	-- Optionally override in your mixin, called when a map inset changes sizes
end

function MapCanvasPinMixin:OnMapInsetMouseEnter(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset gains mouse focus
end

function MapCanvasPinMixin:OnMapInsetMouseLeave(mapInsetIndex)
	-- Optionally override in your mixin, called when a map inset loses mouse focus
end

function MapCanvasPinMixin:ClearNudgeSettings()
	self.nudgeTargetFactor = nil;
	self.nudgeSourceRadius = nil;
	self.nudgeSourceZoomedOutMagnitude = nil;
	self.nudgeSourceZoomedInMagnitude = nil;
	self.zoomedInNudge = nil;
	self.zoomedOutNudge = nil;
end

function MapCanvasPinMixin:SetNudgeTargetFactor(newFactor)
	self.nudgeTargetFactor = newFactor;
end

function MapCanvasPinMixin:GetNudgeTargetFactor()
	return self.nudgeTargetFactor or 0;
end

function MapCanvasPinMixin:SetNudgeSourceRadius(newRadius)
	self.nudgeSourceRadius = newRadius;
end

function MapCanvasPinMixin:GetNudgeSourceRadius()
	return self.nudgeSourceRadius or 0;
end

function MapCanvasPinMixin:SetNudgeSourceMagnitude(nudgeSourceZoomedOutMagnitude, nudgeSourceZoomedInMagnitude)
	self.nudgeSourceZoomedOutMagnitude = nudgeSourceZoomedOutMagnitude;
	self.nudgeSourceZoomedInMagnitude = nudgeSourceZoomedInMagnitude;
end

function MapCanvasPinMixin:GetNudgeSourceZoomedOutMagnitude()
	return self.nudgeSourceZoomedOutMagnitude;
end

function MapCanvasPinMixin:GetNudgeSourceZoomedInMagnitude()
	return self.nudgeSourceZoomedInMagnitude;
end

function MapCanvasPinMixin:SetNudgeZoomedInFactor(newFactor)
	self.zoomedInNudge = newFactor;
end

function MapCanvasPinMixin:GetZoomedInNudgeFactor()
	return self.zoomedInNudge or 0;
end

function MapCanvasPinMixin:SetNudgeZoomedOutFactor(newFactor)
	self.zoomedOutNudge = newFactor;
end

function MapCanvasPinMixin:GetZoomedOutNudgeFactor()
	return self.zoomedOutNudge or 0;
end

function MapCanvasPinMixin:IgnoresNudging()
	return self.insetIndex or (self:GetNudgeSourceRadius() == 0 and self:GetNudgeTargetFactor() == 0);
end

function MapCanvasPinMixin:GetMap()
	return self.owningMap;
end

function MapCanvasPinMixin:GetNudgeVector()
	return self.nudgeVectorX, self.nudgeVectorY;
end

function MapCanvasPinMixin:GetNudgeSourcePinZoomedOutNudgeFactor()
	return self.nudgeSourcePinZoomedOutNudgeFactor or 0;
end

function MapCanvasPinMixin:GetNudgeSourcePinZoomedInNudgeFactor()
	return self.nudgeSourcePinZoomedInNudgeFactor or 0;
end

-- x and y should be a normalized vector.
function MapCanvasPinMixin:SetNudgeVector(sourcePinZoomedOutNudgeFactor, sourcePinZoomedInNudgeFactor, x, y)
	self.nudgeSourcePinZoomedOutNudgeFactor = sourcePinZoomedOutNudgeFactor;
	self.nudgeSourcePinZoomedInNudgeFactor = sourcePinZoomedInNudgeFactor;
	self.nudgeVectorX = x;
	self.nudgeVectorY = y;
	self:ApplyCurrentPosition();
end

function MapCanvasPinMixin:GetNudgeFactor()
	return self.nudgeFactor or 0;
end

function MapCanvasPinMixin:SetNudgeFactor(nudgeFactor)
	self.nudgeFactor = nudgeFactor;
	self:ApplyCurrentPosition();
end

function MapCanvasPinMixin:GetNudgeZoomFactor()
	local zoomPercent = self:GetMap():GetCanvasZoomPercent();
	local targetFactor = Lerp(self:GetZoomedOutNudgeFactor(), self:GetZoomedInNudgeFactor(), zoomPercent);
	local sourceFactor = Lerp(self:GetNudgeSourcePinZoomedOutNudgeFactor(), self:GetNudgeSourcePinZoomedInNudgeFactor(), zoomPercent);
	return targetFactor * sourceFactor;
end

function MapCanvasPinMixin:SetPosition(normalizedX, normalizedY, insetIndex)
	self.normalizedX = normalizedX;
	self.normalizedY = normalizedY;
	self.insetIndex = insetIndex;
	self:GetMap():SetPinPosition(self, normalizedX, normalizedY, insetIndex);
end

-- Returns the global position if not part of an inset, otherwise returns local coordinates of that inset
function MapCanvasPinMixin:GetPosition()
	return self.normalizedX, self.normalizedY, self.insetIndex;
end

-- Returns the global position, even if part of an inset
function MapCanvasPinMixin:GetGlobalPosition()
	if self.insetIndex then
		return self:GetMap():GetGlobalPosition(self.normalizedX, self.normalizedY, self.insetIndex);
	end
	return self.normalizedX, self.normalizedY;
end

function MapCanvasPinMixin:PanTo(normalizedXOffset, normalizedYOffset)
	local normalizedX, normalizedY = self:GetGlobalPosition();
	self:GetMap():PanTo(normalizedX + (normalizedXOffset or 0), (normalizedY or 0));
end

function MapCanvasPinMixin:PanAndZoomTo(normalizedXOffset, normalizedYOffset)
	local normalizedX, normalizedY = self:GetGlobalPosition();
	self:GetMap():PanAndZoomTo(normalizedX + (normalizedXOffset or 0), (normalizedY or 0));
end

function MapCanvasPinMixin:OnCanvasScaleChanged()
	self:ApplyCurrentScale();
	self:ApplyCurrentAlpha();
end

function MapCanvasPinMixin:OnCanvasPanChanged()
	-- Optionally override in your mixin, called when the pan location changes
end

function MapCanvasPinMixin:OnCanvasSizeChanged()
	-- Optionally override in your mixin, called when the canvas size changes
end

function MapCanvasPinMixin:SetIgnoreGlobalPinScale(ignore)
	self.ignoreGlobalPinScale = ignore;
end

function MapCanvasPinMixin:IsIgnoringGlobalPinScale()
	return not not self.ignoreGlobalPinScale;
end

function MapCanvasPinMixin:SetScalingLimits(scaleFactor, startScale, endScale)
	self.scaleFactor = scaleFactor;
	self.startScale = startScale and math.max(startScale, .01) or nil;
	self.endScale = endScale and math.max(endScale, .01) or nil;
end

AM_PIN_SCALE_STYLE_VISIBLE_WHEN_ZOOMED_IN = 1;
AM_PIN_SCALE_STYLE_VISIBLE_WHEN_ZOOMED_OUT = 2;
AM_PIN_SCALE_STYLE_WITH_TERRAIN = 3;

function MapCanvasPinMixin:SetScaleStyle(scaleStyle)
	if scaleStyle == AM_PIN_SCALE_STYLE_VISIBLE_WHEN_ZOOMED_IN then
		self:SetScalingLimits(1.5, 0.0, 2.55);
	elseif scaleStyle == AM_PIN_SCALE_STYLE_VISIBLE_WHEN_ZOOMED_OUT then
		self:SetScalingLimits(1.5, 0.825, 0.0);
	elseif scaleStyle == AM_PIN_SCALE_STYLE_WITH_TERRAIN then
		self:SetScalingLimits(nil, nil, nil);
		if self:IsIgnoringGlobalPinScale() then
			self:SetScale(1.0);
		else
			self:SetScale(self:GetGlobalPinScale());
		end
	end
end

function MapCanvasPinMixin:SetAlphaLimits(alphaFactor, startAlpha, endAlpha)
	self.alphaFactor = alphaFactor;
	self.startAlpha = startAlpha;
	self.endAlpha = endAlpha;
end

AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_IN = 1;
AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_OUT = 2;
AM_PIN_ALPHA_STYLE_ALWAYS_VISIBLE = 3;

function MapCanvasPinMixin:SetAlphaStyle(alphaStyle)
	if alphaStyle == AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_IN then
		self:SetAlphaLimits(2.0, 0.0, 1.0);
	elseif alphaStyle == AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_OUT then
		self:SetAlphaLimits(2.0, 1.0, 0.0);
	elseif alphaStyle == AM_PIN_ALPHA_STYLE_ALWAYS_VISIBLE then
		self:SetAlphaLimits(nil, nil, nil);
	end
end

function MapCanvasPinMixin:ApplyCurrentPosition()
	self:GetMap():ApplyPinPosition(self, self.normalizedX, self.normalizedY, self.insetIndex);
end

function MapCanvasPinMixin:ApplyCurrentScale()
	local scale;
	if self.startScale and self.endScale then
		local parentScaleFactor = 1.0 / self:GetMap():GetCanvasScale();
		scale = parentScaleFactor * Lerp(self.startScale, self.endScale, Saturate(self.scaleFactor * self:GetMap():GetCanvasZoomPercent()));
	elseif not self:IsIgnoringGlobalPinScale() then
		scale = 1;
	end
	if scale then
		if not self:IsIgnoringGlobalPinScale() then
			scale = scale * self:GetMap():GetGlobalPinScale();
		end
		self:SetScale(scale);
		self:ApplyCurrentPosition();
	end

	if self.widgetContainer then
		if self.widgetContainer.FrontModelScene then
			self.widgetContainer.FrontModelScene:RefreshModelScene();
		end

		if self.widgetContainer.BackModelScene then
			self.widgetContainer.BackModelScene:RefreshModelScene();
		end
	end
end

function MapCanvasPinMixin:ApplyCurrentAlpha()
	if self.alphaFactor and self.startAlpha and self.endAlpha then
		local alpha = Lerp(self.startAlpha, self.endAlpha, Saturate(self.alphaFactor * self:GetMap():GetCanvasZoomPercent()));
		self:SetAlpha(alpha);
		self:SetShown(alpha > 0.05);
	end
end

function MapCanvasPinMixin:UseFrameLevelType(pinFrameLevelType, index)
	self.pinFrameLevelType = pinFrameLevelType;
	self.pinFrameLevelIndex = index;
end

function MapCanvasPinMixin:UseFrameLevelTypeFromRangeTop(pinFrameLevelType, index)
	self.pinFrameLevelType = pinFrameLevelType;
	local range = self:GetMap():GetPinFrameLevelsManager():GetFrameLevelRange(pinFrameLevelType);
	index = range - (index or 1) + 1;
	self.pinFrameLevelIndex = index;
end

function MapCanvasPinMixin:GetFrameLevelType(pinFrameLevelType)
	return self.pinFrameLevelType or "PIN_FRAME_LEVEL_DEFAULT";
end

function MapCanvasPinMixin:ApplyFrameLevel()
	local frameLevel = self:GetMap():GetPinFrameLevelsManager():GetValidFrameLevel(self.pinFrameLevelType, self.pinFrameLevelIndex);
	self:SetFrameLevel(frameLevel);

	if self.widgetContainer then
		self.widgetContainer:SetFrameLevel(frameLevel - 10);
	end
end

function MapCanvasPinMixin:GetHighlightType()
	-- Override this in your mixin if your pin needs highlight functionality, determines what kind of highlight to apply to the pin (See MapPinHighlightType)
	return MapPinHighlightType.None;
end

function MapCanvasPinMixin:GetHighlightAnimType()
	-- Override this to change the type of highlight animation to play
	return MapPinHighlightAnimType.ExpandAndFade;
end

function MapCanvasPinMixin:GetDataProvider()
	return self.dataProvider;
end

function MapCanvasPinMixin:SetDataProvider(dataProvider)
	self.dataProvider = dataProvider;
end

function MapCanvasPinMixin:GetDebugInspectionSystem()
	return "MapCanvasPin";
end

function MapCanvasPinMixin:IsPinSuppressor()
	-- Override in your mixin
	return false;
end

function MapCanvasPinMixin:IsSuppressed()
	return self.pinSuppressor ~= nil;
end

function MapCanvasPinMixin:SetSuppressed(suppressor)
	self.pinSuppressor = suppressor;
	self:SetShown(suppressor == nil);
end

function MapCanvasPinMixin:ClearSuppression()
	self:SetSuppressed(nil);
end

function MapCanvasPinMixin:GetPinSuppressor()
	return self.pinSuppressor;
end

function MapCanvasPinMixin:GetDisplayName()
	-- Override in your mixin if needed.
	-- Purposefully asserting here because this should only be called when it can return useful info.
	assertsafe(false);
end

function MapCanvasPinMixin:SetOwningMap(map)
	self.owningMap = map;
	self.lastOwningMapID = map and map:GetMapID() or 0;
end

function MapCanvasPinMixin:GetOwningMap()
	return self.owningMap;
end

function MapCanvasPinMixin:GetLastDisplayMap()
	return self.lastOwningMapID;
end

function MapCanvasPinMixin:ReportPinError(fmt, ...)
	if ProcessExceptionClient then
		local msg = fmt:format(...);
		local framesToSkip = 1;
		ProcessExceptionClient(msg, msg, framesToSkip);

	end
end
