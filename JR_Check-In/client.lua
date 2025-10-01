ESX = exports['es_extended']:getSharedObject() -- Ensure ESX is properly initialized

local beds = {}

-- Find the first available bed
local function findAvailableBed()
    for i, bed in ipairs(Config.BedLocations) do
        if not beds[i] then
            beds[i] = true
            return bed, i
        end
    end
    return nil, nil
end

-- Release bed after use
local function releaseBed(index)
    beds[index] = nil
end

-- Create target zones for check-in locations
for _, loc in ipairs(Config.CheckInLocations) do
    exports.ox_target:addBoxZone({
        coords = loc,
        size = vec3(1, 1, 1),
        rotation = 0,
        options = {
            {
                name = 'checkin',
                event = 'jr_check-in:startCheckIn',
                icon = 'fa-solid fa-hospital',
                label = 'Check In (£' .. Config.CheckInFee .. ')',
                distance = 2.0
            }
        }
    })
end

-- Start check-in process
RegisterNetEvent('jr_check-in:startCheckIn')
AddEventHandler('jr_check-in:startCheckIn', function()
    local player = PlayerPedId()

    -- Start clipboard animation
    RequestAnimDict("missheistdockssetup1clipboard@base")
    while not HasAnimDictLoaded("missheistdockssetup1clipboard@base") do
        Citizen.Wait(100)
    end

    local clipboardModel = `prop_notepad_01`
    RequestModel(clipboardModel)
    while not HasModelLoaded(clipboardModel) do
        Citizen.Wait(100)
    end

    local clipboard = CreateObject(clipboardModel, 0, 0, 0, true, true, false)
    AttachEntityToEntity(clipboard, player, GetPedBoneIndex(player, 57005), 0.1, 0.02, -0.02, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

    TaskPlayAnim(player, "missheistdockssetup1clipboard@base", "base", 8.0, -8.0, -1, 49, 0, false, false, false)

    -- Start check-in progress
    exports.ox_lib:progressCircle({
        duration = Config.CheckInDuration,
        label = "Checking in...",
        useWhileDead = false,
        canCancel = false
    })

    -- Stop animation and remove clipboard
    ClearPedTasks(player)
    DeleteObject(clipboard)

    -- Request payment
    TriggerServerEvent('jr_check-in:payCheckIn')
end)

-- Handle healing process
RegisterNetEvent('jr_check-in:beginTreatment')
AddEventHandler('jr_check-in:beginTreatment', function()
    local player = PlayerPedId()

    -- Find a free bed
	local bed, index = findAvailableBed()
	if not bed then
		lib.notify({
			title = "Hospital",
			description = "No available beds!",
			type = "error", -- Options: success, error, info, warning
			position = "left-center", -- Display notification in the left-center
			duration = 5000 -- Duration in milliseconds (5 seconds)
		})
		return
	end


    -- Fade screen to black
    DoScreenFadeOut(1000)
    Citizen.Wait(1500)

    -- Teleport player to bed
    SetEntityCoords(player, bed.x, bed.y, bed.z)
    SetEntityHeading(player, bed.w)

    -- Load lying animation
    RequestAnimDict("misslamar1dead_body")
    while not HasAnimDictLoaded("misslamar1dead_body") do
        Citizen.Wait(100)
    end

    -- Start laying on back animation
    TaskPlayAnim(player, "misslamar1dead_body", "dead_idle", 8.0, -8.0, -1, 1, 0, false, false, false)

    Citizen.Wait(1000)
    DoScreenFadeIn(1000)

    -- Start healing progress
    exports.ox_lib:progressBar({
        duration = Config.HealDuration,
        label = "Receiving treatment...",
        useWhileDead = false,
        canCancel = false,
        disable = { move = true, car = true, combat = true }
    })

    -- Heal player
    SetEntityHealth(player, 200)

    -- Call the server to restore hunger and thirst
    TriggerServerEvent('jr_check-in:restoreStats')

    -- 3D text appears **instantly**
    local waitingForExit = true

    Citizen.CreateThread(function()
        while waitingForExit do
            Citizen.Wait(0)
            -- Instantly draw "Press E to get out of bed" text
            DrawText3D(bed.x, bed.y, bed.z + 0.5, "~g~[E]~w~ Get Out of Bed")

            -- Disable movement until player gets up
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 32, true)
            DisableControlAction(0, 33, true)
            DisableControlAction(0, 34, true)
            DisableControlAction(0, 35, true)
        end
    end)

    -- Wait for player to press E
    while waitingForExit do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 38) then -- E key
            waitingForExit = false
        end
    end

    -- Play the get-up animation
    RequestAnimDict("switch@franklin@bed")
    while not HasAnimDictLoaded("switch@franklin@bed") do
        Citizen.Wait(100)
    end

    -- Play get-up animation immediately
    TaskPlayAnim(player, "switch@franklin@bed", "sleep_getup_rubeyes", 8.0, -8.0, 3000, 1, 0, false, false, false)
    Citizen.Wait(3000) -- Ensures full animation plays

    -- Clear animation and release the bed
    ClearPedTasksImmediately(player)
    releaseBed(index)

    lib.notify({
    title = "Hospital",
    description = "You are now fully healed and ready to go!",
    type = "success",
    position = "left-center",
    duration = 5000
})
end)

-- Function to draw 3D text instantly
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.5, 0.5)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextOutline()
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
