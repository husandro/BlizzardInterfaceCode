local ArtifactUI =
{
	Name = "ArtifactUI",
	Type = "System",
	Namespace = "C_ArtifactUI",

	Functions =
	{
		{
			Name = "AddPower",
			Type = "Function",

			Arguments =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ApplyCursorRelicToSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "CanApplyArtifactRelic",
			Type = "Function",

			Arguments =
			{
				{ Name = "relicItemID", Type = "number", Nilable = false },
				{ Name = "onlyUnlocked", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "canApply", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanApplyCursorRelicToSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "canApply", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanApplyRelicItemIDToEquippedArtifactSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "relicItemID", Type = "number", Nilable = false },
				{ Name = "relicSlotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "canApply", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanApplyRelicItemIDToSlot",
			Type = "Function",

			Arguments =
			{
				{ Name = "relicItemID", Type = "number", Nilable = false },
				{ Name = "relicSlotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "canApply", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CheckRespecNPC",
			Type = "Function",

			Returns =
			{
				{ Name = "canRespec", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Clear",
			Type = "Function",
		},
		{
			Name = "ClearForgeCamera",
			Type = "Function",
		},
		{
			Name = "ConfirmRespec",
			Type = "Function",
		},
		{
			Name = "DoesEquippedArtifactHaveAnyRelicsSlotted",
			Type = "Function",

			Returns =
			{
				{ Name = "hasAnyRelicsSlotted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAppearanceInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "appearanceSetIndex", Type = "number", Nilable = false },
				{ Name = "appearanceIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
				{ Name = "appearanceName", Type = "string", Nilable = false },
				{ Name = "displayIndex", Type = "number", Nilable = false },
				{ Name = "unlocked", Type = "bool", Nilable = false },
				{ Name = "failureDescription", Type = "string", Nilable = true },
				{ Name = "uiCameraID", Type = "number", Nilable = false },
				{ Name = "altHandCameraID", Type = "number", Nilable = true },
				{ Name = "swatchColorR", Type = "number", Nilable = false },
				{ Name = "swatchColorG", Type = "number", Nilable = false },
				{ Name = "swatchColorB", Type = "number", Nilable = false },
				{ Name = "modelOpacity", Type = "number", Nilable = false },
				{ Name = "modelSaturation", Type = "number", Nilable = false },
				{ Name = "obtainable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAppearanceInfoByID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "artifactAppearanceSetID", Type = "number", Nilable = false },
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
				{ Name = "appearanceName", Type = "string", Nilable = false },
				{ Name = "displayIndex", Type = "number", Nilable = false },
				{ Name = "unlocked", Type = "bool", Nilable = false },
				{ Name = "failureDescription", Type = "string", Nilable = true },
				{ Name = "uiCameraID", Type = "number", Nilable = false },
				{ Name = "altHandCameraID", Type = "number", Nilable = true },
				{ Name = "swatchColorR", Type = "number", Nilable = false },
				{ Name = "swatchColorG", Type = "number", Nilable = false },
				{ Name = "swatchColorB", Type = "number", Nilable = false },
				{ Name = "modelOpacity", Type = "number", Nilable = false },
				{ Name = "modelSaturation", Type = "number", Nilable = false },
				{ Name = "obtainable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAppearanceSetInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "appearanceSetIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "artifactAppearanceSetID", Type = "number", Nilable = false },
				{ Name = "appearanceSetName", Type = "string", Nilable = false },
				{ Name = "appearanceSetDescription", Type = "string", Nilable = false },
				{ Name = "numAppearances", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetArtifactArtInfo",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "artifactArtInfo", Type = "ArtifactArtInfo", Nilable = false },
			},
		},
		{
			Name = "GetArtifactInfo",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "altItemID", Type = "number", Nilable = true },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "xp", Type = "number", Nilable = false },
				{ Name = "pointsSpent", Type = "number", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
				{ Name = "appearanceModID", Type = "number", Nilable = false },
				{ Name = "itemAppearanceID", Type = "number", Nilable = true },
				{ Name = "altItemAppearanceID", Type = "number", Nilable = true },
				{ Name = "altOnTop", Type = "bool", Nilable = false },
				{ Name = "tier", Type = "ArtifactTiers", Nilable = false },
			},
		},
		{
			Name = "GetArtifactItemID",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetArtifactTier",
			Type = "Function",

			Returns =
			{
				{ Name = "tier", Type = "ArtifactTiers", Nilable = true },
			},
		},
		{
			Name = "GetArtifactXPRewardTargetInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "artifactCategoryID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "GetCostForPointAtRank",
			Type = "Function",

			Arguments =
			{
				{ Name = "rank", Type = "number", Nilable = false },
				{ Name = "tier", Type = "ArtifactTiers", Nilable = false },
			},

			Returns =
			{
				{ Name = "cost", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEquippedArtifactArtInfo",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "artifactArtInfo", Type = "ArtifactArtInfo", Nilable = false },
			},
		},
		{
			Name = "GetEquippedArtifactInfo",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "altItemID", Type = "number", Nilable = true },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "xp", Type = "number", Nilable = false },
				{ Name = "pointsSpent", Type = "number", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
				{ Name = "appearanceModID", Type = "number", Nilable = false },
				{ Name = "itemAppearanceID", Type = "number", Nilable = true },
				{ Name = "altItemAppearanceID", Type = "number", Nilable = true },
				{ Name = "altOnTop", Type = "bool", Nilable = false },
				{ Name = "tier", Type = "ArtifactTiers", Nilable = false },
			},
		},
		{
			Name = "GetEquippedArtifactItemID",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEquippedArtifactNumRelicSlots",
			Type = "Function",

			Arguments =
			{
				{ Name = "onlyUnlocked", Type = "bool", Nilable = false, Default = false, Documentation = { "If true then only the relic slots that are unlocked will be considered." } },
			},

			Returns =
			{
				{ Name = "numRelicSlots", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEquippedArtifactRelicInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "slotTypeName", Type = "cstring", Nilable = false, Documentation = { "Matches the socket identifiers used in the socketing system." } },
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetEquippedRelicLockedReason",
			Type = "Function",

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "lockedReason", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetForgeRotation",
			Type = "Function",

			Returns =
			{
				{ Name = "forgeRotationX", Type = "number", Nilable = false },
				{ Name = "forgeRotationY", Type = "number", Nilable = false },
				{ Name = "forgeRotationZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetItemLevelIncreaseProvidedByRelic",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemLinkOrID", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemIevelIncrease", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMetaPowerInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = false, StrideIndex = 1 },
				{ Name = "powerCost", Type = "number", Nilable = false, StrideIndex = 2 },
				{ Name = "currentRank", Type = "number", Nilable = false, StrideIndex = 3 },
			},
		},
		{
			Name = "GetNumAppearanceSets",
			Type = "Function",

			Returns =
			{
				{ Name = "numAppearanceSets", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumObtainedArtifacts",
			Type = "Function",

			Returns =
			{
				{ Name = "numObtainedArtifacts", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumRelicSlots",
			Type = "Function",

			Arguments =
			{
				{ Name = "onlyUnlocked", Type = "bool", Nilable = false, Default = false, Documentation = { "If true then only the relic slots that are unlocked will be considered." } },
			},

			Returns =
			{
				{ Name = "numRelicSlots", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPointsRemaining",
			Type = "Function",

			Returns =
			{
				{ Name = "pointsRemaining", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPowerHyperlink",
			Type = "Function",

			Arguments =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "link", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetPowerInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "powerInfo", Type = "ArtifactPowerInfo", Nilable = false },
			},
		},
		{
			Name = "GetPowerLinks",
			Type = "Function",

			Arguments =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "linkingPowerID", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetPowers",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "powerID", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetPowersAffectedByRelic",
			Type = "Function",

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "powerIDs", Type = "number", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetPowersAffectedByRelicItemLink",
			Type = "Function",

			Arguments =
			{
				{ Name = "relicItemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "powerIDs", Type = "number", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetPreviewAppearance",
			Type = "Function",

			Returns =
			{
				{ Name = "artifactAppearanceID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetRelicInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "slotTypeName", Type = "cstring", Nilable = false, Documentation = { "Matches the socket identifiers used in the socketing system." } },
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetRelicInfoByItemID",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "slotTypeName", Type = "cstring", Nilable = false, Documentation = { "Matches the socket identifiers used in the socketing system." } },
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetRelicLockedReason",
			Type = "Function",

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "lockedReason", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetRelicSlotType",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "relicSlotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "slotTypeName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetRespecArtifactArtInfo",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "artifactArtInfo", Type = "ArtifactArtInfo", Nilable = false },
			},
		},
		{
			Name = "GetRespecArtifactInfo",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "altItemID", Type = "number", Nilable = true },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "xp", Type = "number", Nilable = false },
				{ Name = "pointsSpent", Type = "number", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
				{ Name = "appearanceModID", Type = "number", Nilable = false },
				{ Name = "itemAppearanceID", Type = "number", Nilable = true },
				{ Name = "altItemAppearanceID", Type = "number", Nilable = true },
				{ Name = "altOnTop", Type = "bool", Nilable = false },
				{ Name = "tier", Type = "ArtifactTiers", Nilable = false },
			},
		},
		{
			Name = "GetRespecCost",
			Type = "Function",

			Returns =
			{
				{ Name = "cost", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTotalPowerCost",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "startingTrait", Type = "luaIndex", Nilable = false },
				{ Name = "numTraits", Type = "number", Nilable = false },
				{ Name = "artifactTier", Type = "ArtifactTiers", Nilable = false },
			},

			Returns =
			{
				{ Name = "totalArtifactPowerCost", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTotalPurchasedRanks",
			Type = "Function",

			Returns =
			{
				{ Name = "totalPurchasedRanks", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsArtifactDisabled",
			Type = "Function",

			Returns =
			{
				{ Name = "artifactDisabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsArtifactItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isArtifact", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAtForge",
			Type = "Function",

			Returns =
			{
				{ Name = "isAtForge", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEquippedArtifactDisabled",
			Type = "Function",

			Returns =
			{
				{ Name = "artifactDisabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEquippedArtifactMaxed",
			Type = "Function",

			Returns =
			{
				{ Name = "artifactMaxed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMaxedByRulesOrEffect",
			Type = "Function",

			Returns =
			{
				{ Name = "isEffectivelyMaxed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPowerKnown",
			Type = "Function",

			Arguments =
			{
				{ Name = "powerID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "known", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsViewedArtifactEquipped",
			Type = "Function",

			Returns =
			{
				{ Name = "isViewedArtifactEquipped", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAppearance",
			Type = "Function",

			Arguments =
			{
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetForgeCamera",
			Type = "Function",
		},
		{
			Name = "SetForgeRotation",
			Type = "Function",

			Arguments =
			{
				{ Name = "forgeRotationX", Type = "number", Nilable = false },
				{ Name = "forgeRotationY", Type = "number", Nilable = false },
				{ Name = "forgeRotationZ", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPreviewAppearance",
			Type = "Function",
			Documentation = { "Call without an argument to clear the preview." },

			Arguments =
			{
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "ShouldSuppressForgeRotation",
			Type = "Function",

			Returns =
			{
				{ Name = "shouldSuppressForgeRotation", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ArtifactClose",
			Type = "Event",
			LiteralName = "ARTIFACT_CLOSE",
		},
		{
			Name = "ArtifactEndgameRefund",
			Type = "Event",
			LiteralName = "ARTIFACT_ENDGAME_REFUND",
			Payload =
			{
				{ Name = "numRefundedPowers", Type = "number", Nilable = false },
				{ Name = "refundedTier", Type = "ArtifactTiers", Nilable = false },
				{ Name = "bagOrSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "ArtifactRelicForgeClose",
			Type = "Event",
			LiteralName = "ARTIFACT_RELIC_FORGE_CLOSE",
		},
		{
			Name = "ArtifactRelicForgePreviewRelicChanged",
			Type = "Event",
			LiteralName = "ARTIFACT_RELIC_FORGE_PREVIEW_RELIC_CHANGED",
		},
		{
			Name = "ArtifactRelicForgeUpdate",
			Type = "Event",
			LiteralName = "ARTIFACT_RELIC_FORGE_UPDATE",
		},
		{
			Name = "ArtifactRelicInfoReceived",
			Type = "Event",
			LiteralName = "ARTIFACT_RELIC_INFO_RECEIVED",
		},
		{
			Name = "ArtifactRespecPrompt",
			Type = "Event",
			LiteralName = "ARTIFACT_RESPEC_PROMPT",
		},
		{
			Name = "ArtifactTierChanged",
			Type = "Event",
			LiteralName = "ARTIFACT_TIER_CHANGED",
			Payload =
			{
				{ Name = "newTier", Type = "luaIndex", Nilable = false },
				{ Name = "bagOrSlotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "ArtifactUpdate",
			Type = "Event",
			LiteralName = "ARTIFACT_UPDATE",
			Payload =
			{
				{ Name = "newItem", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ArtifactXpUpdate",
			Type = "Event",
			LiteralName = "ARTIFACT_XP_UPDATE",
		},
	},

	Tables =
	{
		{
			Name = "ArtifactAppearanceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
				{ Name = "appearanceName", Type = "string", Nilable = false },
				{ Name = "displayIndex", Type = "number", Nilable = false },
				{ Name = "unlocked", Type = "bool", Nilable = false },
				{ Name = "failureDescription", Type = "string", Nilable = true },
				{ Name = "uiCameraID", Type = "number", Nilable = false },
				{ Name = "altHandCameraID", Type = "number", Nilable = true },
				{ Name = "swatchColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
				{ Name = "modelOpacity", Type = "number", Nilable = false },
				{ Name = "modelSaturation", Type = "number", Nilable = false },
				{ Name = "obtainable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ArtifactAppearanceSetInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "artifactAppearanceSetID", Type = "number", Nilable = false },
				{ Name = "appearanceSetName", Type = "string", Nilable = false },
				{ Name = "appearanceSetDescription", Type = "string", Nilable = false },
				{ Name = "numAppearances", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ArtifactArtInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "titleName", Type = "string", Nilable = false },
				{ Name = "titleColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
				{ Name = "barConnectedColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
				{ Name = "barDisconnectedColor", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
				{ Name = "uiModelSceneID", Type = "number", Nilable = false },
				{ Name = "spellVisualKitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ArtifactInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "altItemID", Type = "number", Nilable = true },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "xp", Type = "number", Nilable = false },
				{ Name = "pointsSpent", Type = "number", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "artifactAppearanceID", Type = "number", Nilable = false },
				{ Name = "appearanceModID", Type = "number", Nilable = false },
				{ Name = "itemAppearanceID", Type = "number", Nilable = true },
				{ Name = "altItemAppearanceID", Type = "number", Nilable = true },
				{ Name = "altOnTop", Type = "bool", Nilable = false },
				{ Name = "tier", Type = "ArtifactTiers", Nilable = false },
			},
		},
		{
			Name = "ArtifactMetaPowerInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "powerCost", Type = "number", Nilable = false },
				{ Name = "currentRank", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ArtifactPowerInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "cost", Type = "number", Nilable = false },
				{ Name = "currentRank", Type = "number", Nilable = false },
				{ Name = "maxRank", Type = "number", Nilable = false },
				{ Name = "bonusRanks", Type = "number", Nilable = false },
				{ Name = "numMaxRankBonusFromTier", Type = "number", Nilable = false },
				{ Name = "prereqsMet", Type = "bool", Nilable = false },
				{ Name = "isStart", Type = "bool", Nilable = false },
				{ Name = "isGoldMedal", Type = "bool", Nilable = false },
				{ Name = "isFinal", Type = "bool", Nilable = false },
				{ Name = "tier", Type = "luaIndex", Nilable = false },
				{ Name = "position", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "offset", Type = "vector2", Mixin = "Vector2DMixin", Nilable = true },
				{ Name = "linearIndex", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "ArtifactRelicInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "slotTypeName", Type = "cstring", Nilable = false, Documentation = { "Matches the socket identifiers used in the socketing system." } },
				{ Name = "link", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ArtifactUI);