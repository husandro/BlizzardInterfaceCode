function CallErrorHandler(...)
	SetErrorCallstackHeight(GetCallstackHeight() - 1); -- report error from the previous function
	local result = geterrorhandler()(...);
	SetErrorCallstackHeight(nil);
	return result;
end

function assertsafe(cond, msgStringOrFunction, ...)
	if not cond then
		local error = msgStringOrFunction or "non-fatal assertion failed";
		if type(msgStringOrFunction) == 'string' and select('#', ...) > 0 then
			error = msgStringOrFunction:format(...);
		elseif type(msgStringOrFunction) == 'function' then
			error = msgStringOrFunction(...);
		end

		SetErrorCallstackHeight(GetCallstackHeight() - 1); -- report error from the previous function
		if geterrorhandler() then
			geterrorhandler()(error);
		elseif ProcessExceptionClient then
			local framesToSkip = 1;
			ProcessExceptionClient(error, error, framesToSkip);

		end
		SetErrorCallstackHeight(nil);
	end
end
