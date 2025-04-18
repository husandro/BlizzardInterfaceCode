local CurrencyConstants_Mainline =
{
	Tables =
	{
		{
			Name = "CurrencyDestroyReason",
			Type = "Enumeration",
			NumValues = 16,
			MinValue = 0,
			MaxValue = 15,
			Fields =
			{
				{ Name = "Cheat", Type = "CurrencyDestroyReason", EnumValue = 0 },
				{ Name = "Spell", Type = "CurrencyDestroyReason", EnumValue = 1 },
				{ Name = "VersionUpdate", Type = "CurrencyDestroyReason", EnumValue = 2 },
				{ Name = "QuestTurnin", Type = "CurrencyDestroyReason", EnumValue = 3 },
				{ Name = "Vendor", Type = "CurrencyDestroyReason", EnumValue = 4 },
				{ Name = "Trade", Type = "CurrencyDestroyReason", EnumValue = 5 },
				{ Name = "Capped", Type = "CurrencyDestroyReason", EnumValue = 6 },
				{ Name = "Garrison", Type = "CurrencyDestroyReason", EnumValue = 7 },
				{ Name = "DroppedToCorpse", Type = "CurrencyDestroyReason", EnumValue = 8 },
				{ Name = "BonusRoll", Type = "CurrencyDestroyReason", EnumValue = 9 },
				{ Name = "FactionConversion", Type = "CurrencyDestroyReason", EnumValue = 10 },
				{ Name = "FulfillCraftingOrder", Type = "CurrencyDestroyReason", EnumValue = 11 },
				{ Name = "Script", Type = "CurrencyDestroyReason", EnumValue = 12 },
				{ Name = "ConcentrationCast", Type = "CurrencyDestroyReason", EnumValue = 13 },
				{ Name = "AccountTransfer", Type = "CurrencyDestroyReason", EnumValue = 14 },
				{ Name = "HonorLoss", Type = "CurrencyDestroyReason", EnumValue = 15 },
			},
		},
		{
			Name = "CurrencySource",
			Type = "Enumeration",
			NumValues = 67,
			MinValue = 0,
			MaxValue = 66,
			Fields =
			{
				{ Name = "ConvertOldItem", Type = "CurrencySource", EnumValue = 0 },
				{ Name = "ConvertOldPvPCurrency", Type = "CurrencySource", EnumValue = 1 },
				{ Name = "ItemRefund", Type = "CurrencySource", EnumValue = 2 },
				{ Name = "QuestReward", Type = "CurrencySource", EnumValue = 3 },
				{ Name = "Cheat", Type = "CurrencySource", EnumValue = 4 },
				{ Name = "Vendor", Type = "CurrencySource", EnumValue = 5 },
				{ Name = "PvPKillCredit", Type = "CurrencySource", EnumValue = 6 },
				{ Name = "PvPMetaCredit", Type = "CurrencySource", EnumValue = 7 },
				{ Name = "PvPScriptedAward", Type = "CurrencySource", EnumValue = 8 },
				{ Name = "Loot", Type = "CurrencySource", EnumValue = 9 },
				{ Name = "UpdatingVersion", Type = "CurrencySource", EnumValue = 10 },
				{ Name = "LFGReward", Type = "CurrencySource", EnumValue = 11 },
				{ Name = "Trade", Type = "CurrencySource", EnumValue = 12 },
				{ Name = "Spell", Type = "CurrencySource", EnumValue = 13 },
				{ Name = "ItemDeletion", Type = "CurrencySource", EnumValue = 14 },
				{ Name = "RatedBattleground", Type = "CurrencySource", EnumValue = 15 },
				{ Name = "RandomBattleground", Type = "CurrencySource", EnumValue = 16 },
				{ Name = "Arena", Type = "CurrencySource", EnumValue = 17 },
				{ Name = "ExceededMaxQty", Type = "CurrencySource", EnumValue = 18 },
				{ Name = "PvPCompletionBonus", Type = "CurrencySource", EnumValue = 19 },
				{ Name = "Script", Type = "CurrencySource", EnumValue = 20 },
				{ Name = "GuildBankWithdrawal", Type = "CurrencySource", EnumValue = 21 },
				{ Name = "Pushloot", Type = "CurrencySource", EnumValue = 22 },
				{ Name = "GarrisonBuilding", Type = "CurrencySource", EnumValue = 23 },
				{ Name = "PvPDrop", Type = "CurrencySource", EnumValue = 24 },
				{ Name = "GarrisonFollowerActivation", Type = "CurrencySource", EnumValue = 25 },
				{ Name = "GarrisonBuildingRefund", Type = "CurrencySource", EnumValue = 26 },
				{ Name = "GarrisonMissionReward", Type = "CurrencySource", EnumValue = 27 },
				{ Name = "GarrisonResourceOverTime", Type = "CurrencySource", EnumValue = 28 },
				{ Name = "QuestRewardIgnoreCapsDeprecated", Type = "CurrencySource", EnumValue = 29 },
				{ Name = "GarrisonTalent", Type = "CurrencySource", EnumValue = 30 },
				{ Name = "GarrisonWorldQuestBonus", Type = "CurrencySource", EnumValue = 31 },
				{ Name = "PvPHonorReward", Type = "CurrencySource", EnumValue = 32 },
				{ Name = "BonusRoll", Type = "CurrencySource", EnumValue = 33 },
				{ Name = "AzeriteRespec", Type = "CurrencySource", EnumValue = 34 },
				{ Name = "WorldQuestReward", Type = "CurrencySource", EnumValue = 35 },
				{ Name = "WorldQuestRewardIgnoreCapsDeprecated", Type = "CurrencySource", EnumValue = 36 },
				{ Name = "FactionConversion", Type = "CurrencySource", EnumValue = 37 },
				{ Name = "DailyQuestReward", Type = "CurrencySource", EnumValue = 38 },
				{ Name = "DailyQuestWarModeReward", Type = "CurrencySource", EnumValue = 39 },
				{ Name = "WeeklyQuestReward", Type = "CurrencySource", EnumValue = 40 },
				{ Name = "WeeklyQuestWarModeReward", Type = "CurrencySource", EnumValue = 41 },
				{ Name = "AccountCopy", Type = "CurrencySource", EnumValue = 42 },
				{ Name = "WeeklyRewardChest", Type = "CurrencySource", EnumValue = 43 },
				{ Name = "GarrisonTalentTreeReset", Type = "CurrencySource", EnumValue = 44 },
				{ Name = "DailyReset", Type = "CurrencySource", EnumValue = 45 },
				{ Name = "AddConduitToCollection", Type = "CurrencySource", EnumValue = 46 },
				{ Name = "Barbershop", Type = "CurrencySource", EnumValue = 47 },
				{ Name = "ConvertItemsToCurrencyValue", Type = "CurrencySource", EnumValue = 48 },
				{ Name = "PvPTeamContribution", Type = "CurrencySource", EnumValue = 49 },
				{ Name = "Transmogrify", Type = "CurrencySource", EnumValue = 50 },
				{ Name = "AuctionDeposit", Type = "CurrencySource", EnumValue = 51 },
				{ Name = "PlayerTrait", Type = "CurrencySource", EnumValue = 52 },
				{ Name = "PhBuffer_53", Type = "CurrencySource", EnumValue = 53 },
				{ Name = "PhBuffer_54", Type = "CurrencySource", EnumValue = 54 },
				{ Name = "RenownRepGain", Type = "CurrencySource", EnumValue = 55 },
				{ Name = "CraftingOrder", Type = "CurrencySource", EnumValue = 56 },
				{ Name = "CatalystBalancing", Type = "CurrencySource", EnumValue = 57 },
				{ Name = "CatalystCraft", Type = "CurrencySource", EnumValue = 58 },
				{ Name = "ProfessionInitialAward", Type = "CurrencySource", EnumValue = 59 },
				{ Name = "PlayerTraitRefund", Type = "CurrencySource", EnumValue = 60 },
				{ Name = "AccountHwmUpdate", Type = "CurrencySource", EnumValue = 61 },
				{ Name = "ConvertItemsToCurrencyAndReputation", Type = "CurrencySource", EnumValue = 62 },
				{ Name = "PhBuffer_63", Type = "CurrencySource", EnumValue = 63 },
				{ Name = "SpellSkipLinkedCurrency", Type = "CurrencySource", EnumValue = 64 },
				{ Name = "AccountTransfer", Type = "CurrencySource", EnumValue = 65 },
				{ Name = "RenownRepGainInitialVisibility", Type = "CurrencySource", EnumValue = 66 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CurrencyConstants_Mainline);