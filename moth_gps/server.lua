ESX = nil

local Users = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function RemoveFromTable(playerid)
    for k, v in pairs(Users) do
        if v.id == playerid then
            table.remove(Users, k)
            break
        end
    end
end

function AddToTable(playerid, name, jobname)
    for _, v in pairs(Users) do
        if v.id == playerid then
            return 'alreadyin'
        end
    end

    local xPlayer = ESX.GetPlayerFromId(playerid)
    local coords = xPlayer.getCoords(true)

    local data = {
        id = playerid,
        name = name,
        x = coords.x,
        y = coords.y,
        z = coords.z,
        job = jobname
    }

    table.insert(Users, data)
end

ESX.RegisterServerCallback('moth:removeUser', function(source, cb)
    local source = source
    RemoveFromTable(source)
    cb()
end)

Citizen.CreateThread(function()
    while true do
        if Users == nil then
            Users = {}
        end

        for _, v in pairs(Users) do
            local xPlayer = ESX.GetPlayerFromId(v.id)
            local coords = xPlayer.getCoords(true)
            v.x = coords.x
            v.y = coords.y
            v.z = coords.z

            local players = ESX.GetPlayers()

            for i = 1, #players do
                local xPlayer = ESX.GetPlayerFromId(players[i])

                if xPlayer.job.name == v.job then
                    local temp = {}

                    for _, v in pairs(Users) do
                        if v.job == xPlayer.job.name then
                            table.insert(temp, v)
                        end
                    end

                    TriggerClientEvent('moth:updatepositions', players[i], temp)
                    temp = {}
                end
            end
        end

        Wait(Config.Updateinterval * 1000)
    end
end)

ESX.RegisterUsableItem(Config.GPSItem, function(playerid)
    local player = ESX.GetPlayerFromId(playerid)
    local jobname = player.job.name

    for _, v in pairs(Config.Whitelistedjobs) do
        if v == jobname then
            local succeeded = AddToTable(playerid, player.name, jobname)

            if succeeded == 'alreadyin' then
                TriggerClientEvent('esx:showNotification', playerid, 'GPS erfolgreich deaktiviert')
                RemoveFromTable(playerid)
            else
                TriggerClientEvent('esx:showNotification', playerid, 'GPS aktiviert')
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    RemoveFromTable(source)
end)