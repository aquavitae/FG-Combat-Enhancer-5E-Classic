--  Please see the COPYRIGHT.txt file included with this distribution for attribution and copyright information.

--[[
-- Check the version and inform of incompatibility
]]--

local SUPPORTED_VERSION = "3.3.8";

function onInit()
	if Session.IsHost then
		local nMajor,nMinor,nSub = Interface.getVersion();
		local sVersion =  tostring(nMajor) .. '.' .. tostring(nMinor) .. '.' .. tostring(nSub);
		local extInfo = Extension.getExtensionInfo("5e Combat Enhancer");
		nExtVer = 'UNKNOWN';

		-- For some reason FG cannot get the extension for some people?
		if extInfo then
			nExtVer = extInfo.version;
		end

		if nMajor == 3 and nMinor == 3 and nSub == 8 then
			Debug.console('5e Enhanced Combat Version check: Version is ' .. SUPPORTED_VERSION .. ', and valid');
		else
			Debug.console('5e Enhanced Combat Version check: Invalid version ' .. sVersion);
			error("VERSION :" .. sVersion .. ' is not supported for 5e Combat Enhancer ' .. nExtVer .. ', it is only supported for ' .. SUPPORTED_VERSION .. '  use at your own risk!');
		end
	end
end
