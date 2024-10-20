CachedJob = nil


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true
    local Job = lib.callback.await('dalle:returnjob', false)
    for k, v in ipairs(Config.Jobs) do
        if v == Job then
            LoadCalls(Job)
            CachedJob = v
            break
        end
    end
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
    ESX.PlayerLoaded = false
    ESX.PlayerData = {}
    CachedJob = nil
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
    local found = false
    for _, v in ipairs(Config.Jobs) do
        if v == job.name then
            LoadCalls(job.name)
            CachedJob = v
            found = true
            break
        end
    end
    if not found then
        CachedJob = nil
    end
end)

function GetJob()
    return ESX.PlayerData.job.name
end
