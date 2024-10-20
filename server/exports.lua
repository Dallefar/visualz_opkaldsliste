function GetPhoneNumber(identifier)
	local nummer = nil
	vRP.getUserIdentity({
		identifier,
		function(identity)
			if identity.firstname and identity.name then
				nummer = identity.phone
			end
		end,
	})
	if nummer ~= nil then
		return nummer
	end
	return nil
end

function SendTakenMessage(identifier, number, fromnumber, xPlayer)
	exports["lb-phone"]:SendMessage(number, fromnumber, Config.takecall)
end

function SendCallMessage(identifier, number, fromnumber, message, xPlayer)
	local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
	if xPlayer == nil then
		return
	end
	exports["lb-phone"]:SendMessage(number, fromnumber, message)
end

function GetPlayer(source)
	local xPlayer = vRP.getUserId({ source })
	if xPlayer == nil then return end
	return xPlayer
end

function GetIdentifier(source)
	if xPlayer == nil then
		return
	end
	return xPlayer
end

function GetPlayerFromIdentifier(identifier)
	local xPlayer = vRP.getUserSource({ identifier })
	if xPlayer == nil then
		return
	end
	return xPlayer
end

function SendToAddCall(number, call)
	local xPlayers = GetExtendedPlayers("job", number) -- Returns xPlayers with the police job
	for _, xPlayer in pairs(xPlayers) do
		TriggerClientEvent("visualz_opkaldsliste:client:addCall", xPlayer, call)
	end
end

function GetExtendedPlayers(type, number)
	local players = {}
	for _, playerId in ipairs(GetPlayers()) do
		local user_id = vRP.getUserId({ playerId })
		local job = vRP.getUserGroupByType({ user_id, "job" })
		if job == number then
			table.insert(players, playerId)
		end
	end
	return players
end

function UpdateCall(number, name, onCall, onCallPlayers, id)
	local xPlayers = GetExtendedPlayers("job", number) -- Returns xPlayers with the police job
	-- print(name)
	for _, xPlayer in pairs(xPlayers) do
		TriggerClientEvent("visualz_opkaldsliste:client:updateCall", xPlayer, name, onCall, onCallPlayers, id)
	end
end

function DeleteCall(number, id)
	local xPlayers = GetExtendedPlayers("job", number) -- Returns xPlayers with the police job
	for _, xPlayer in pairs(xPlayers) do
		TriggerClientEvent("visualz_opkaldsliste:client:deleteCall", xPlayer, id)
	end
end

function DeleteAll(number, sourcePlayer)
	vRP.getUserIdentity({
		user_id,
		function(identity)
			if identity.firstname and identity.name then
				local name = sourcePlayer.getName()
				name = identity.firstname .. " " .. identity.name
				local xPlayers = GetExtendedPlayers("job", number) -- Returns xPlayers with the police job
				for _, xPlayer in pairs(xPlayers) do
					print("Triggered")
					TriggerClientEvent("visualz_opkaldsliste:client:deleteAll", xPlayer, name)
				end
			end
		end,
	})
end
