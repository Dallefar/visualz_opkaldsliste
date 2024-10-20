-- -------------------------------------------------------------------------- --
--                                  Variables                                 --
-- -------------------------------------------------------------------------- --
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")

local calls = {}
local callid = {}

-- Config load jobs for id
for k, v in ipairs(Config.Jobs) do
	callid[v] = 0
end

-- Config load jobs
for k, v in ipairs(Config.Jobs) do
	calls[v] = {}
end

-- Test call
-- RegisterCommand('test_call', function(src, args)
--     AddCall(d, "Test call! Skynd jer!", "police", { x = 0, z = 0, y = 0 })
-- end, false)

-- -------------------------------------------------------------------------- --
--                                  Functions                                 --
-- -------------------------------------------------------------------------- --

function AddCall(src, message, number, coords)
	for k, v in ipairs(Config.Jobs) do
		if v == number then
			local ped = nil

			local playerCoords = nil
			local identifier69 = nil
			local phonenumber = nil

			if src == nil then
				if type(coords) == "table" then
					if coords.x == nil or coords.y == nil or coords.z == nil then
						print("Fejl: Ugyldige koordinater, brug vector3(x, y, z) eller {x = 0, y = 0, z = 0}")
						return
					end
					playerCoords = vector3(coords.x, coords.y, coords.z)
				elseif type(coords) == "vector3" then
					playerCoords = coords
				else
					print("Fejl: Ugyldige koordinater, brug vector3(x, y, z) eller {x = 0, y = 0, z = 0}")
				end
				identifier69 = nil
				phonenumber = Config.AutomaticMessage
			else
				ped = GetPlayerPed(src)
				playerCoords = GetEntityCoords(ped)
				local xPlayer = GetPlayer(src)
				if xPlayer then
					identifier69 = GetPlayer(src)
					phonenumber = GetPhoneNumber(xPlayer)
				else
					identifier69 = nil
					phonenumber = Config.AutomaticMessage
				end
			end

			local data = {
				identifier = identifier69,
				date = os.date("%x %X"),
				message = message,
				taken = nil,
				deleted = false,
				fromnumber = phonenumber,
				number = number,
				coords = playerCoords,
				onCall = 0,
				onCallPlayers = {},
				id = callid[number] + 1,
			}
			callid[number] = callid[number] + 1
			table.insert(calls[number], data)
			SendToAddCall(number, calls[number][callid[number]])
		end
	end
end

-- -------------------------------------------------------------------------- --
--                                 Net Events                                 --
-- -------------------------------------------------------------------------- --

RegisterNetEvent("visualz_opkaldsliste:server:takeCall")
AddEventHandler("visualz_opkaldsliste:server:takeCall", function(id, number)
	local xPlayer = GetPlayerFromIdentifier(calls[number][id].identifier)
	local sourcePlayer = GetPlayer(source)
	local job = getjob(xPlayer)
	local plyname = nil
	vRP.getUserIdentity({
		xPlayer,
		function(identity)
			if identity.firstname and identity.name then
				plyname = identity.firstname .. " " .. identity.name
			end

            print(plyname)
			local identifier = calls[number][id].identifier
			if job == number then
				if identifier ~= nil and calls[number][id]["onCallPlayers"][identifier] == nil then
					calls[number][id]["onCallPlayers"][identifier] = plyname
					calls[number][id].onCall = calls[number][id].onCall + 1

					if calls[number][id]["taken"] == nil then
						calls[number][id]["taken"] = plyname
						if
							Config.SendTakenMessage
							and calls[number][id].fromnumber ~= Config.AutomaticMessage
							and xPlayer ~= nil
							and xPlayer ~= nil
						then
							-- SendTakenMessage(calls[number][id].identifier, calls[number][id].number, calls[number][id].fromnumber, xPlayer)
						end
					end

					UpdateCall(
						number,
						calls[number][id]["taken"],
						calls[number][id].onCall,
						calls[number][id].onCallPlayers,
						id
					)
				end
			end
		end,
	})
end)

RegisterNetEvent("visualz_opkaldsliste:server:dropCall")
AddEventHandler("visualz_opkaldsliste:server:dropCall", function(id, number)
	local xPlayer = GetPlayerFromIdentifier(calls[number][id].identifier)
	local sourcePlayer = GetPlayer(source)
	local identifier = GetIdentifier(source)
	if sourcePlayer.job.name == number then
		if identifier ~= nil and calls[number][id]["onCallPlayers"][identifier] ~= nil then
			calls[number][id]["onCallPlayers"][identifier] = nil
			calls[number][id].onCall = calls[number][id].onCall - 1

			UpdateCall(
				number,
				calls[number][id]["taken"],
				calls[number][id].onCall,
				calls[number][id].onCallPlayers,
				id
			)
		end
	end
end)

RegisterNetEvent("visualz_opkaldsliste:server:deleteCall")
AddEventHandler("visualz_opkaldsliste:server:deleteCall", function(id, number)
	local sourcePlayer = GetPlayer(source)
	if getjob(sourcePlayer) == number then
		calls[number][id]["deleted"] = true
		DeleteCall(number, id)
	end
end)

RegisterNetEvent("visualz_opkaldsliste:server:deleteAll")
AddEventHandler("visualz_opkaldsliste:server:deleteAll", function(number)
	local sourcePlayer = GetPlayer(source)
	if getjob(sourcePlayer) == number then
		calls[number] = {}
		callid[number] = 0
		DeleteAll(number, sourcePlayer)
	end
end)

RegisterNetEvent("visualz_opkaldsliste:server:sendMessage")
AddEventHandler("visualz_opkaldsliste:server:sendMessage", function(number, message, id)
	SendCallMessage(calls[number][id].identifier, number, calls[number][id].fromnumber, message)
end)

-- -------------------------------------------------------------------------- --
--                               ServerCallbacks                              --
-- -------------------------------------------------------------------------- --
lib.callback.register("visualz_opkaldsliste:loadCalls", function(source, number)
	return calls[number]
end)

lib.callback.register("visualz_opkaldsliste:loadIdentifier", function()
	return GetIdentifier(source)
end)

RegisterCommand("Getname", function()
	local name = getName(1)
	print(name)
end)

function getjob(source)
	local user_id = vRP.getUserId({ source })
	local job = vRP.getUserGroupByType({ user_id, "job" })

	return job
end

lib.callback.register("dalle:returnjob", function(source)
	local job = getjob(source)
	return job
end)

-- declare export
exports("AddCall", AddCall)

RegisterCommand("opkald", function(source, args, rawCommand)
	local message = table.concat(args, " ")
	-- exports['visualz_opkaldsliste']:AddCall(nil, message, job, coords)
	exports["visualz_opkaldsliste"]:AddCall(source, message, "Mekaniker")
end, false)
