ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('jr_check-in:payCheckIn')
AddEventHandler('jr_check-in:payCheckIn', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    local paymentMethod = Config.PaymentMethod
    local price = Config.CheckInFee
    local playerHasMoney = false

    if paymentMethod == "cash" then
        playerHasMoney = xPlayer.getMoney() >= price
    elseif paymentMethod == "bank" then
        playerHasMoney = xPlayer.getAccount('bank').money >= price
    end

    if playerHasMoney then
        if paymentMethod == "cash" then
            xPlayer.removeMoney(price)
        else
            xPlayer.removeAccountMoney('bank', price)
        end

        -- Start healing process on client
        TriggerClientEvent('jr_check-in:beginTreatment', source)

        -- ox_lib notification for successful payment
        TriggerClientEvent('ox_lib:notify', source, {
            title = "Hospital",
            description = "You paid £" .. price .. " for treatment.",
            type = "success",
            position = "left-center",
            duration = 5000
        })

    else
        -- ox_lib notification for insufficient funds
        TriggerClientEvent('ox_lib:notify', source, {
            title = "Hospital",
            description = "You don't have enough money.",
            type = "error",
            position = "left-center",
            duration = 5000
        })
    end
end)

-- Give full health, food, and water after healing
RegisterNetEvent('jr_check-in:restoreStats')
AddEventHandler('jr_check-in:restoreStats', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    -- Fully restore player health
    TriggerClientEvent('esx_basicneeds:healPlayer', source)

    -- Ensure hunger and thirst are set correctly (for ESX Legacy)
    if xPlayer.getAccount('hunger') then
        xPlayer.setAccountMoney('hunger', 100)
    end

    if xPlayer.getAccount('thirst') then
        xPlayer.setAccountMoney('thirst', 100)
    end

    -- Notify player that they are fully recovered
    TriggerClientEvent('ox_lib:notify', source, {
        title = "Hospital",
        description = "You feel completely refreshed and energized!",
        type = "success",
        position = "left-center",
        duration = 5000
    })
end)
