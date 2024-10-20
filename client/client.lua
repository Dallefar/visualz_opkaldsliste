-- -------------------------------------------------------------------------- --
--                                  Variables                                 --
-- -------------------------------------------------------------------------- --
local ui = false;
local ready = false;
local identifier = nil;


RegisterNetEvent('HT_base:playerLoaded')
AddEventHandler('HT_base:playerLoaded', function(xPlayer, isNew, skin)
  CreateThread(function()
    lib.callback('visualz_opkaldsliste:loadIdentifier', false, function(identifierCall)
      identifier = identifierCall
    end)
  end)
end)

-- -------------------------------------------------------------------------- --
--                                  Functions                                 --
-- -------------------------------------------------------------------------- --

-- Load calls fucntion
function LoadCalls(job)
  local calls = lib.callback.await("visualz_opkaldsliste:loadCalls", false, job)
  SendNUIMessage({
    action = "loadCalls",
    data = {
      calls = calls,
      number = job
    }
  })
end

-- Toggle UI function
function SetDisplay(bool, job)
  ui = bool
  SetNuiFocus(bool, bool)
  SendNUIMessage({
    action = "show",
    data = {
      number = job,
      status = bool,
      identifier = identifier
    }
  })
end

-- -------------------------------------------------------------------------- --
--                                  Commands                                  --
-- -------------------------------------------------------------------------- --

-- Open UI command
RegisterKeyMapping('opkaldsliste', 'Åbner opkaldsliste', 'keyboard', Config.HotKey)
RegisterCommand('opkaldsliste', function()
    if ready then
      print("Triggered")
        local Job = lib.callback.await('dalle:returnjob', false)
        for k, v in ipairs(Config.Jobs) do
            if v == Job then
                local job = v
                SetDisplay(not ui, job)
                return
            end
        end
    end
end, false)

-- -------------------------------------------------------------------------- --
--                                NUI Callbacks                               --
-- -------------------------------------------------------------------------- --

-- Nui callback, closes the UI
RegisterNUICallback("exit", function(data, cb)
  SetDisplay(false)
  cb("ok")
end)

RegisterNUICallback("takeCall", function(data, cb)
  SetNewWaypoint(data.coords.x, data.coords.y)
  TriggerServerEvent("visualz_opkaldsliste:server:takeCall", data.id, data.number)
  cb("ok")
end)

RegisterNUICallback("dropCall", function(data, cb)
  TriggerServerEvent("visualz_opkaldsliste:server:dropCall", data.id, data.number)
  cb("ok")
end)

RegisterNUICallback("setGps", function(data, cb)
  SetNewWaypoint(data.coords.x, data.coords.y)
  cb("ok")
end)

RegisterNUICallback("deleteCall", function(data, cb)
  TriggerServerEvent("visualz_opkaldsliste:server:deleteCall", data.id, data.number)
  cb("ok")
end)

RegisterNUICallback("sendMessage", function(data, cb)
  TriggerServerEvent("visualz_opkaldsliste:server:sendMessage", data.number, data.message, data.id)
  cb("ok")
end)

RegisterNUICallback("deleteAll", function(data, cb)
  TriggerServerEvent("visualz_opkaldsliste:server:deleteAll", data.number)
  cb("ok")
end)

RegisterNUICallback("getSettings", function(data, cb)
  cb({
    Sounds = Config.Sounds
  })
end)

RegisterNUICallback("isLoading", function(data, cb)
  lib.notify({
    id = 'opkaldsliste',
    title = 'Opkaldsliste',
    description = 'Indlæser opkaldslisten',
    type = 'inform'
  })
  cb("ok")
end)

RegisterNUICallback("isReady", function(data, cb)
  ready = true
  lib.notify({
    id = 'opkaldsliste',
    title = 'Opkaldsliste',
    description = 'Opkaldslisten er klar til brug',
    type = 'success'
  })
  cb("ok")
end)

-- -------------------------------------------------------------------------- --
--                                 Net Events                                 --
-- -------------------------------------------------------------------------- --

RegisterNetEvent("visualz_opkaldsliste:client:addCall")
AddEventHandler("visualz_opkaldsliste:client:addCall", function(data2, id)
  local streetName, _ = GetStreetNameAtCoord(data2.coords.x, data2.coords.y, data2.coords.z)
  local streetName = GetStreetNameFromHashKey(streetName)
  SendNUIMessage({
    action = "addCall",
    data = {
      id = data2.id,
      date = data2.date,
      message = data2.message,
      number = data2.number,
      fromnumber = data2.fromnumber,
      street = streetName,
      coords = data2.coords,
      deleted = data2.deleted,
      onCall = data2.onCall,
      onCallPlayers = data2.onCallPlayers,
    },
  })
end)

RegisterNetEvent("visualz_opkaldsliste:client:updateCall")
AddEventHandler("visualz_opkaldsliste:client:updateCall", function(name, onCall, onCallPlayers, id)
  SendNUIMessage({
    action = "updateCall",
    data = {
      id = id,
      name = name,
      onCall = onCall,
      onCallPlayers = onCallPlayers
    }
  })
end)

RegisterNetEvent("visualz_opkaldsliste:client:deleteCall")
AddEventHandler("visualz_opkaldsliste:client:deleteCall", function(id)
  SendNUIMessage({
    action = "deleteCall",
    data = {
      id = id
    }
  })
end)

RegisterNetEvent("visualz_opkaldsliste:client:deleteAll")
AddEventHandler("visualz_opkaldsliste:client:deleteAll", function(name)
  SendNUIMessage({
    action = "deleteAll",
    data = {
      name = name
    }
  })
end)
