--  Please see the COPYRIGHT.txt file included with this distribution for attribution and copyright information.


local sInternal = "";

function setEffect(sEffect)
	setText(sEffect);
	sInternal = sEffect;
end

function getEffect()
	return {
		sName = sInternal,
		nGMOnly = 0,
		};
end

function onDragStart(button, x, y, draginfo)
	local rEffect = getEffect();
	return ActionEffect.performRoll(draginfo, nil, rEffect);
end

function onButtonPress(x, y)
	local rEffect = getEffect();
	local rRoll = ActionEffect.getRoll(nil, nil, rEffect);
	local tokenCT,rTarget;
	if not rRoll then
		return true;
	end

	if not Session.IsHost then
		local iden = User.getCurrentIdentity();
		if not iden then
			Comm.addChatMessage({text="Select an identity first before attempting to apply an effect!",secret=true});
			return true;
		end
	end

	local contextToken = MiniEffect.getLastContextToken();
	local miniMode = MiniEffect.getMode();

	-- if our context token was deleted, destroy the 'context' window!
	if not MiniEffect.isContextTokenValid() then
		local wnd = Interface.findWindow('minieffects','effects');
		if wnd then
			wnd.close();
		end
		return true;
	end

	rRoll.sType = "effect";
	if miniMode == 'context' then
		--Debug.console('context mode is active');
		tokenCT = CombatManager.getCTFromToken(contextToken);
		if tokenCT then
			rTarget = ActorManager.getActorFromCT(tokenCT);
			Debug.console('rTarget is : ' .. tostring(rTarget));
			ActionsManager.resolveAction(nil,rTarget,rRoll);
		end
	elseif miniMode == 'targeted' then
		-- apply to all actors this token is targeting
		Debug.console('targeted mode is active');
		tokenCT = CombatManager.getCTFromToken(contextToken);
		if tokenCT then
			if not Session.IsHost then
				local sFaction = DB.getValue(tokenCT, "friendfoe", "");
				if sFaction ~= 'friend' then
					Comm.addChatMessage({text="You cannont put effects for targets of a token you do not control",secret=true});
					return true;
				end
			end
			rTarget = ActorManager.getActorFromCT(tokenCT);
			local tokenActorTargets = TargetingManager.getFullTargets(rTarget);
			for k,v in pairs(tokenActorTargets) do
				ActionsManager.resolveAction(nil,v,rRoll);
			end
		end
	elseif miniMode == 'selected' then
		-- apply to all selected tokens on open windows
		Debug.console('selected mode is active');
		applyEffectOnOpenImageWindows(rRoll,rEffect);
	else
		Debug.console('UNKNOWN MINI MODE ' .. tostring(miniMode));
	end

--[[
	rRoll.sType = "effect";
	local rTarget = nil;
	if Session.IsHost then
		applyEffectOnOpenImageWindows(rRoll,rEffect);
	else
		local iden = User.getCurrentIdentity();
		if iden then
			rTarget = ActorManager.getActor("pc", CombatManager.getCTFromNode("charsheet." .. User.getCurrentIdentity()));
			ActionsManager.resolveAction(nil, rTarget, rRoll);
			--applyEffectOnOpenImageWindows(rRoll,rEffect);
		else
			Comm.addChatMessage({text="Select an identity first before attempting to apply an effect to yourself!",secret=true});
		end
	end
]]--

	return true;
end

function applyEffectOnOpenImageWindows(rRoll,rEffect)
	local imgWnds = DB.findNode('image');
	local wnd;
	--Debug.console(tostring(imgWnds));

	if imgWnds then
		imgWnds = imgWnds.getChildren();
		--Debug.console(tostring(imgWnds));
		for k,v in pairs(imgWnds) do
			--Debug.console(tostring(v.getPath()));
			wnd = getOpenImgWindow(v);
			if wnd then
				--Debug.console('window ' .. v.getPath() .. ' is open!');
				local tokens = getSelectedTokens(wnd);
				local tokenCTs = getTokenCTs(tokens);
				local rTarget;
				for k,v in pairs(tokenCTs) do
					rTarget = ActorManager.getActorFromCT(v);
					ActionsManager.resolveAction(nil,rTarget,rRoll);
					--Debug.console("using EA rather than RA!'");
					--EffectManager.addEffect(sUser,nil,v,rEffect,true);
				end
			end
		end
	end
end

function getTokenCTs(tokens)
	local retval = {};
	local tokenCT;
	for k,v in pairs(tokens) do
		tokenCT = CombatManager.getCTFromToken(v);
		if tokenCT then
			table.insert(retval,tokenCT);
		end
	end
	--Debug.console("we found " .. #retval .. " connected CT Tokens");
	return retval;
end

function getSelectedTokens(imgWindow)
	local retval = {};
	local controls = imgWindow.getControls();

	if #controls > 0 then
		local imgCtls = {};
		for k,v in pairs(controls) do
			local ctlName = v.getName();
			if ctlName == "play_image"
			or ctlName == "features_image"
			or ctlName == "image" then
				table.insert(imgCtls,v);
			end
		end

		for k,v in pairs(imgCtls) do
			imgTokens = v.getSelectedTokens();
			for k2,v2 in pairs(imgTokens) do
				table.insert(retval,v2);
			end
		end
	end

	--Debug.console("we found " .. #retval .. " selected tokens");
	return retval;
end

function getOpenImgWindow(imgDbNode)
	local retval = nil;
	retval = Interface.findWindow("imagewindow",imgDbNode);
	return retval;
end

