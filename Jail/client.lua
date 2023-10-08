ESX = nil
local isInJail = false
local jailCoords = {
    x = 1774.02,
    y = 2552.06,
    z = 45.56,
    rot = 90.1,
}
local lastPlayerCoords
local remainingSeconds = 0

-- Definiere den Bereich, in dem der Spieler sich aufhalten muss
local jailArea = {
    x = 1774.02,
    y = 2552.06,
    z = 45.56,
    radius = 300.0 -- Radius des Gefängnisbereichs, in dem der Spieler bleiben muss
}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterCommand("jail", function(source, args, rawCommand)
    ESX.TriggerServerCallback('Jail:getJob', function(jobname)
        if jobname == 'police' then
            print(args[1])
            TriggerServerEvent('Jail:sendToJail', tonumber(args[1]), tonumber(args[2]))
        end
    end)
end)

RegisterCommand("freejail", function()
    local playerPed = PlayerPedId()
    if isInJail then
        ShowNotification('~g~Du wurdest aus dem Gefängnis entlassen')
        SetEntityCoords(playerPed, lastPlayerCoords.x, lastPlayerCoords.y, lastPlayerCoords.z)
        EnableControlAction(1, 141, true) -- Aktiviere Laufen
        EnableControlAction(1, 142, true) -- Aktiviere Laufen
        isInJail = false
        remainingSeconds = 0
    else
        ShowNotification('~r~Du bist nicht im Gefängnis!')
    end
end)

RegisterNetEvent('Jail:goToJail')
AddEventHandler('Jail:goToJail', function(seconds)
    goToJail(seconds)
end)

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = GetDistanceBetweenCoords(playerCoords, jailArea.x, jailArea.y, jailArea.z, true)

        if isInJail and distance > jailArea.radius then
            -- Wenn der Spieler sich außerhalb des Gefängnisbereichs befindet, teleportiere ihn zurück
            ShowNotification('~r~Du hast den Gefängnisbereich verlassen!')
            goToJail(remainingSeconds) -- Hier wird der Spieler während der Zeit zurückteleportiert

        end 

        if isInJail and remainingSeconds > 0 then
            remainingSeconds = remainingSeconds - 1
            if remainingSeconds == 5 or remainingSeconds == 10 or remainingSeconds == 20 then
                ShowNotification('~r~Es verbleiben noch ~y~ ' .. remainingSeconds .. ' Sekunden')
            end
        
        elseif isInJail and remainingSeconds == 0 then
            isInJail = false
            ShowNotification('~g~Du wirst nun entlassen')
            SetEntityCoords(playerPed, lastPlayerCoords.x, lastPlayerCoords.y, lastPlayerCoords.z)
            EnableControlAction(1, 141, true) -- Aktiviere Laufen
            EnableControlAction(1, 142, true) -- Aktiviere Laufe
        
        end

        Citizen.Wait(1000)
    end
end)

function goToJail(seconds)
    local playerPed = PlayerPedId()
    lastPlayerCoords = GetEntityCoords(playerPed)
    isInJail = true
    remainingSeconds = seconds
    SetEntityCoords(playerPed, jailCoords.x, jailCoords.y, jailCoords.z)
    SetEntityHeading(playerPed, jailCoords.rot)
    ShowNotification('~r~Du bist nun für ~y~' .. seconds .. ' Sekunden ~r~im Gefängnis!')
    DisableControlAction(1, 141, true) -- Deaktiviere Laufen
    DisableControlAction(1, 142, true) -- Deaktiviere Laufen
end

function ShowNotification(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, true)
end