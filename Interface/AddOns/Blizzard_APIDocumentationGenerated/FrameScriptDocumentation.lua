local FrameScript =
{
	Name = "FrameScript",
	Type = "System",

	Functions =
	{
		{
			Name = "CreateWindow",
			Type = "Function",

			Arguments =
			{
				{ Name = "popupStyle", Type = "bool", Nilable = false, Default = true },
				{ Name = "topMost", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "window", Type = "SimpleWindow", Nilable = true },
			},
		},
		{
			Name = "GetCallstackHeight",
			Type = "Function",

			Returns =
			{
				{ Name = "height", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCurrentEventID",
			Type = "Function",

			Returns =
			{
				{ Name = "eventID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetErrorCallstackHeight",
			Type = "Function",

			Returns =
			{
				{ Name = "height", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetEventTime",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "eventProfileIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "totalElapsedTime", Type = "number", Nilable = false },
				{ Name = "numExecutedHandlers", Type = "number", Nilable = false },
				{ Name = "slowestHandlerName", Type = "cstring", Nilable = false },
				{ Name = "slowestHandlerTime", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSourceLocation",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "location", Type = "string", Nilable = false },
			},
		},
		{
			Name = "RunScript",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetErrorCallstackHeight",
			Type = "Function",

			Arguments =
			{
				{ Name = "height", Type = "number", Nilable = true },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(FrameScript);