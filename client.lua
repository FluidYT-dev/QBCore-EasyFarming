-- client.lua
local QBCore = exports['qb-core']:GetCoreObject()
local isInZone = false
local sellerPed = nil

CreateThread(function()
    local blip = AddBlipForCoord(Config.PickupZone.coords.x, Config.PickupZone.coords.y, Config.PickupZone.coords.z)
    SetBlipSprite(blip, 85)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Apfel Sammelzone")
    EndTextCommandSetBlipName(blip)

    local sellBlip = AddBlipForCoord(Config.SellLocation.coords.x, Config.SellLocation.coords.y, Config.SellLocation.coords.z)
    SetBlipSprite(sellBlip, 52)
    SetBlipDisplay(sellBlip, 4)
    SetBlipScale(sellBlip, 0.8)
    SetBlipColour(sellBlip, 1)
    SetBlipAsShortRange(sellBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Apfel Ankauf")
    EndTextCommandSetBlipName(sellBlip)
end)

CreateThread(function()
    RequestModel(`a_m_m_farmer_01`)
    while not HasModelLoaded(`a_m_m_farmer_01`) do
        Wait(100)
    end

    sellerPed = CreatePed(4, `a_m_m_farmer_01`, Config.SellLocation.coords.x, Config.SellLocation.coords.y, Config.SellLocation.coords.z - 1.0, Config.SellLocation.coords.w, false, true)
    SetEntityInvincible(sellerPed, true)
    SetBlockingOfNonTemporaryEvents(sellerPed, true)
    FreezeEntityPosition(sellerPed, true)
end)

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.PickupZone.coords)
        
        if distance < Config.PickupZone.radius then
            isInZone = true
            DrawMarker(28, Config.PickupZone.coords.x, Config.PickupZone.coords.y, Config.PickupZone.coords.z - 1.7, 0, 0, 0, 0, 0, 0, Config.PickupZone.radius * 2, Config.PickupZone.radius * 2, 1.0, 0, 255, 0, 100, false, false, 2, false, nil, nil, false) -- Marker tiefer setzen
            if IsControlJustReleased(0, 38) then -- "E" Taste
                TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true) -- Animation starten
                QBCore.Functions.Progressbar("collecting_apple", "Sammle Apfel...", Config.CollectTime, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    ClearPedTasks(playerPed) -- Animation stoppen
                    TriggerServerEvent('qb-farming:collectApple')
                end, function() -- Cancel
                    ClearPedTasks(playerPed) -- Animation stoppen
                    TriggerEvent('QBCore:Notify', 'Du hast das Sammeln abgebrochen.', 'error')
                end)
            end
        else
            isInZone = false
        end
        Wait(0)
    end
end)

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sellDistance = #(playerCoords - vector3(Config.SellLocation.coords.x, Config.SellLocation.coords.y, Config.SellLocation.coords.z))
        
        if sellDistance < 2.0 then
            DrawText3D(Config.SellLocation.coords.x, Config.SellLocation.coords.y, Config.SellLocation.coords.z + 1.0, "Presse [E] um Apfel zu verkaufen")
            if IsControlJustReleased(0, 38) then -- "E" Taste
                TriggerServerEvent('qb-farming:sellApples')
            end
        end
        Wait(0)
    end
end)

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end