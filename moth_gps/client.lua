ESX = nil

local BlipData = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('moth:updatepositions', function(data)
    for _, v in pairs(BlipData) do
        RemoveBlip(v)
    end

    BlipData = {}

    for _, v in pairs(data) do
        local blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(blip, 280)
        SetBlipColour(blip, 1)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(blip)
        table.insert(BlipData, blip)
    end
end)

if Config.RemoveOnDeath then
    AddEventHandler('esx:onPlayerDeath', function(data)
        ESX.TriggerServerCallback('moth:removeUser', function()
        end)
    end)
end