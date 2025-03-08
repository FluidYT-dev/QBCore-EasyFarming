QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-farming:collectApple', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddItem(Config.ItemName, 1)
        TriggerClientEvent('QBCore:Notify', src, 'Du hast einen Apfel gesammelt!', 'success')
    end
end)

RegisterNetEvent('qb-farming:sellApples', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local item = Player.Functions.GetItemByName(Config.ItemName)
        if item and item.amount > 0 then
            local totalPrice = item.amount * Config.SellPrice
            Player.Functions.RemoveItem(Config.ItemName, item.amount)
            Player.Functions.AddMoney('cash', totalPrice)
            TriggerClientEvent('QBCore:Notify', src, 'Du hast '..item.amount..'x Apfel für $'..totalPrice..' verkauft.', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Du hast keinen Apfel zum Verkaufen.', 'error')
        end
    end
end)