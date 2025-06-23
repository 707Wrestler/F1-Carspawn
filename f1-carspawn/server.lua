QBCore = exports['qb-core']:GetCoreObject()

local vehicles = {
    { name = "T20", model = "t20" },
    { name = "Raid", model = "tolraid" }
}

QBCore.Functions.CreateCallback('wstudio:fetchVehicles', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local vehicles = Player.PlayerData.vehicles or {} 

    cb(vehicles)
end)

RegisterNetEvent("wstudio:fetchVehicles")
AddEventHandler("wstudio:fetchVehicles", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    
    local playerVehicles = {}

    
    for _, vehicle in ipairs(vehicles) do
        table.insert(playerVehicles, vehicle)
    end

    
    exports.oxmysql:execute("SELECT vehicle FROM player_vehicles WHERE citizenid = ?", {citizenid}, function(results)
        for _, v in ipairs(results) do
            table.insert(playerVehicles, { name = v.vehicle, model = v.vehicle })
        end

        
        TriggerClientEvent("wstudio:openMenu", src, playerVehicles)
    end)
end)
