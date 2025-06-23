local QBCore = exports['qb-core']:GetCoreObject()

local isMenuOpen = false
local currentVehicle = nil
local vehicles = {}
local customVehicles = {}

-- Yasaklı alan merkezi ve yarıçap
local restrictedZoneCenter = vector3(-7110.96, 1920.84, 2095.2)
local restrictedZoneRadius = 500.0

RegisterCommand('openVehicleMenu', function()
    local playerPed = PlayerPedId()

    -- Araçtayken kontrol
    if IsPedInAnyVehicle(playerPed, false) then
        QBCore.Functions.Notify("Araçta F1 menüsünü açamazsın.", "error")
        return
    end

    -- Belirli bölgede mi kontrol
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - restrictedZoneCenter)
    if distance < restrictedZoneRadius then
        QBCore.Functions.Notify("Bu alanda F1 menüsünü kullanamazsın.", "error")
        return
    end

    -- Araç listesi çek
    TriggerServerEvent("wstudio:fetchVehicles") 
end, false)

RegisterKeyMapping('openVehicleMenu', 'Araç Çıkarma Menüsü', 'keyboard', Config.MenuKey)

RegisterNetEvent("wstudio:openMenu")
AddEventHandler("wstudio:openMenu", function(fetchedVehicles)
    vehicles = fetchedVehicles
    customVehicles = {} -- Her açıldığında temizleyin

    if vehicles and #vehicles > 0 then
        for _, vehicle in pairs(vehicles) do
            local emoji = "🚗"
            if vehicle.isOwned then
                emoji = "👤"
            end
            table.insert(customVehicles, { name = vehicle.name .. " " .. emoji, model = vehicle.model })
        end
    end

    if not isMenuOpen then
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "openMenu",
            vehicles = vehicles,
            customVehicles = customVehicles,
            resourceName = GetCurrentResourceName()
        })
        isMenuOpen = true
    else
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "closeMenu"
        })
        isMenuOpen = false
    end
end)

RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    isMenuOpen = false
    cb('ok')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) 

        if currentVehicle then
            local playerPed = PlayerPedId()

            if not IsPedInAnyVehicle(playerPed, false) then
                local delay = (Config.VehicleDeleteDelay or 5) * 1000
                Citizen.Wait(delay)

                if currentVehicle and not IsPedInAnyVehicle(playerPed, false) then
                    DeleteVehicle(currentVehicle)
                    currentVehicle = nil
                end
            end
        end
    end
end)


RegisterNUICallback('spawnVehicle', function(data, cb)
    local vehicleName = data.vehicleName
    local vehicleModel = ""

    for _, v in pairs(vehicles) do
        if v.name == vehicleName then
            vehicleModel = v.model
            break
        end
    end

    if vehicleModel ~= "" then
        local playerPed = PlayerPedId()

        if currentVehicle then
            DeleteVehicle(currentVehicle)
            currentVehicle = nil
        end

        RequestModel(vehicleModel)
        while not HasModelLoaded(vehicleModel) do
            Wait(1)
        end

        local pos = GetEntityCoords(playerPed)
        local spawnedVehicle = CreateVehicle(vehicleModel, pos.x, pos.y, pos.z, GetEntityHeading(playerPed), true, false)
        
        SetPedIntoVehicle(playerPed, spawnedVehicle, -1)
        
        local plate = Config.Plate
        SetVehicleNumberPlateText(spawnedVehicle, plate)

        currentVehicle = spawnedVehicle

        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "closeMenu"
        })

        cb('ok')
    else
        cb('error')
    end
end)
