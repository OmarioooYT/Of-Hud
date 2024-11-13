local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local HudShow = false
local harness = false
local seatbeltOn = false
local loaded = false
local stress = 0
local config = Config
distance = nil
direction = nil
local speedMultiplier = 3.6
local oxygen, moneyboost, bleed, alcohol = 100, 0, 0, 0
PlayerData = QBCore.Functions.GetPlayerData()

RegisterNetEvent('hud:client:UpdateStress', function(newStress) -- Add this event with adding stress elsewhere
    stress = newStress
end)

if not config.DisableStress then
    CreateThread(function() -- Speeding
        while true do
            if LocalPlayer.state.isLoggedIn then
                local ped = PlayerPedId()
                if IsPedInAnyVehicle(ped, false) then
                    local veh = GetVehiclePedIsIn(ped, false)
                    local vehClass = GetVehicleClass(veh)
                    local speed = GetEntitySpeed(veh) * speedMultiplier
                    local vehHash = GetEntityModel(veh)
                    if config.VehClassStress[tostring(vehClass)] and not config.WhitelistedVehicles[vehHash] then
                        local stressSpeed
                        if vehClass == 8 then -- Motorcycle exception for seatbelt
                            stressSpeed = config.MinimumSpeed
                        else
                            stressSpeed = seatbeltOn and config.MinimumSpeed or config.MinimumSpeedUnbuckled
                        end
                        if speed >= stressSpeed then
                            TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                        end
                    end
                end
            end
            Wait(10000)
        end
    end)

    CreateThread(function() -- Shooting
        while true do
            if LocalPlayer.state.isLoggedIn then
                local ped = PlayerPedId()
                local weapon = GetSelectedPedWeapon(ped)
                if weapon ~= `WEAPON_UNARMED` then
                    if IsPedShooting(ped) and not config.WhitelistedWeaponStress[weapon] then
                        if math.random() < config.StressChance then
                            TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                        end
                    end
                else
                    Wait(1000)
                end
            end
            Wait(0)
        end
    end)
end

local function GetBlurIntensity(stresslevel)
    for _, v in pairs(config.Intensity['blur']) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.intensity
        end
    end
    return 1500
end

local function GetEffectInterval(stresslevel)
    for _, v in pairs(config.EffectInterval) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.timeout
        end
    end
    return 60000
end

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local effectInterval = GetEffectInterval(stress)
        if stress >= 100 then
            local BlurIntensity = GetBlurIntensity(stress)
            local FallRepeat = math.random(2, 4)
            local RagdollTimeout = FallRepeat * 1750
            TriggerScreenblurFadeIn(1000.0)
            Wait(BlurIntensity)
            TriggerScreenblurFadeOut(1000.0)

            if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                SetPedToRagdollWithFall(ped, RagdollTimeout, RagdollTimeout, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            end

            Wait(1000)
            for _ = 1, FallRepeat, 1 do
                Wait(750)
                DoScreenFadeOut(200)
                Wait(1000)
                DoScreenFadeIn(200)
                TriggerScreenblurFadeIn(1000.0)
                Wait(BlurIntensity)
                TriggerScreenblurFadeOut(1000.0)
            end
        elseif stress >= config.MinimumStress then
            local BlurIntensity = GetBlurIntensity(stress)
            TriggerScreenblurFadeIn(1000.0)
            Wait(BlurIntensity)
            TriggerScreenblurFadeOut(1000.0)
        end
        Wait(effectInterval)
    end
end)

function getPlayerInfo()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    return playerCoords, playerHeading
end

-- Function to get player's current coordinates
function getPlayerCoords()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    return playerCoords.x, playerCoords.y, playerCoords.z
end

-- Function to get waypoint coordinates
function getWaypointCoords()
    local waypointBlip = GetFirstBlipInfoId(8) -- 8 corresponds to the waypoint blip
    if DoesBlipExist(waypointBlip) then
        local waypointCoords = GetBlipInfoIdCoord(waypointBlip)
        return waypointCoords.x, waypointCoords.y, waypointCoords.z
    else
        return nil, nil, nil
    end
end

function getWaypointCoords1()
    local waypointBlip = GetFirstBlipInfoId(8) -- 8 corresponds to the waypoint blip
    if DoesBlipExist(waypointBlip) then
        local waypointCoords = GetBlipInfoIdCoord(waypointBlip)
        return waypointCoords
    else
        return nil
    end
end

function getDirectionToWaypoint()
    local playerCoords, playerHeading = getPlayerInfo()
    local waypointCoords = getWaypointCoords1()

    if waypointCoords then
        local dx = waypointCoords.x - playerCoords.x
        local dy = waypointCoords.y - playerCoords.y
        local angleToWaypoint = math.deg(math.atan2(dy, dx))
        local relativeAngle = angleToWaypoint - playerHeading

        -- Normalize the relative angle to the range of -180 to 180 degrees
        relativeAngle = (relativeAngle + 180) % 360 - 180

        if relativeAngle >= -45 and relativeAngle < 45 then
            return "Right"
        elseif relativeAngle >= 22.5 and relativeAngle < 67.5 then
            return "Halfright"
        elseif relativeAngle >= 45 and relativeAngle < 135 then
            return "Front"
        elseif relativeAngle >= 112.5 and relativeAngle < 157.5 then
            return "Halfleft"
        elseif relativeAngle >= -135 and relativeAngle < -45 then
            return "Back"
        else
            return "Left"
        end
    else
        return "None"
    end
end


-- Register a command to test the direction calculation to the waypoint
-- RegisterCommand("directionToWaypoint", function(source, args, rawCommand)
--     local direction = getDirectionToWaypoint()
--     print("The direction to the waypoint is: " .. direction)
-- end, false)

-- Register a command to test the distance calculation to the waypoint
-- RegisterCommand("distanceToWaypoint", function(source, args, rawCommand)
--     local playerX, playerY, playerZ = getPlayerCoords()
--     local waypointX, waypointY, waypointZ = getWaypointCoords()

--     if waypointX and waypointY and waypointZ then
--         local distance = GetDistanceBetweenCoords(playerX, playerY, playerZ, waypointX, waypointY, waypointZ, true) / 1000
--         print(string.format("The distance to the waypoint is %.2f km.", distance))
--     else
--         print("No waypoint set.")
--     end
-- end, false)

-- Example usage: /distanceToWaypoint (no additional arguments needed)

RegisterNetEvent("QBCore:Player:SetPlayerData", function(val)
    PlayerData = val
end)

RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function() -- Triggered in smallresources
    seatbeltOn = not seatbeltOn
end)

RegisterNetEvent('seatbelt:client:ToggleCruise', function() -- Triggered in ressmallources
    cruiseOn = not cruiseOn
end)

RegisterNetEvent('seatbelt:client:ToggleHarness', function(Newharness)
    harness = Newharness
end)

local lastFuelUpdate = 0
local lastFuelCheck = {}
local function GetFuelLevel(vehicle)
    local updateTick = GetGameTimer()
    if (updateTick - lastFuelUpdate) > 2000 then
        lastFuelUpdate = updateTick
        lastFuelCheck = math.floor(exports['LegacyFuel']:GetFuel(vehicle))
    end
    return lastFuelCheck
end

function getProximityStatus()
    local proximity = "whisper"

    -- Attempt to retrieve the proximity distance from the player's state
    if LocalPlayer and LocalPlayer.state and LocalPlayer.state['proximity'] then
        proximity = LocalPlayer.state['proximity'].distance
    end

    -- Debug print to check the proximity value
    -- if proximity then
    --     print("Proximity distance retrieved:", proximity)
    -- else
    --     print("Proximity data not available or distance is nil.")
    -- end

    -- print(type(proxmity))
    -- Check if proximity data is available and return the appropriate status

        if proximity == 1.5 then
            return "whisper"
        elseif proximity == 3.0 then
            return "normal"
        elseif proximity == 6.0 then
            return "loud"
        end

end





    function HudStart()
    TriggerEvent('hud:client:LoadMap')

    while true do
        if LocalPlayer.state.isLoggedIn then
            if loaded then
            HudShow = true
            else
                HudShow = false
            end
            local playerId = PlayerId()
            local player = PlayerPedId()
            local sprint = GetEntitySpeed(player)
            local playerdied = IsPlayerDead(player)

            local playerX, playerY, playerZ = getPlayerCoords()
            local waypointX, waypointY, waypointZ = getWaypointCoords()
        
            if waypointX and waypointY and waypointZ then
             distance = GetDistanceBetweenCoords(playerX, playerY, playerZ, waypointX, waypointY, waypointZ, true) / 1000
            else
             distance = '--'
            end

            local vehicle = GetVehiclePedIsIn(player, false)
            local VehicleSpeed = math.ceil(GetEntitySpeed(vehicle) * speedMultiplier)
            local VehicleFuel = GetFuelLevel(vehicle)
            local CheckHarnass = exports['qb-smallresources']:HasHarness()
            local CheckSeatbelt = exports['qb-smallresources']:HasSeatbelt()
             direct = getDirectionToWaypoint()
            local status = getProximityStatus()
            if CheckHarnass or not CheckSeatbelt then harness = CheckHarnass end
            if CheckSeatbelt or not CheckSeatbelt then seatbeltOn = CheckSeatbelt end

            armour = GetPedArmour(player)
            health = GetEntityHealth(player) - 100
            local oxygenLevel = GetPlayerUnderwaterTimeRemaining(PlayerId())
            local scaledOxygenLevel = oxygenLevel * 10
            -- print(scaledOxygenLevel)
            local heading = GetEntityHeading(PlayerPedId())

            if IsPauseMenuActive() then HudShow = false end
            if playerdied then HudShow = false end
            if not IsEntityInWater(player) then oxygen = 100 - GetPlayerSprintStaminaRemaining(playerId) end
            if IsEntityInWater(player) then oxygen = GetPlayerUnderwaterTimeRemaining(playerId) * 10 end

            local playerCoords = GetEntityCoords(player, true)
            local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y,
                playerCoords.z, currentStreetHash, intersectStreetHash)
            currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
            zone = tostring(GetNameOfZone(playerCoords))
            area = GetLabelText(zone)
            if area == "Fort Zancudo" then area = "Williamsburg"  elseif area == "Downtown Vinewood" then area = "D.T Vinewood" elseif area == "Grand Senora Desert" then area = "G.S Desert" elseif area == "San Chianski Mountain Range" then area = "San Chianski FR" end

            local veh = GetVehiclePedIsIn(playerPed)
            if not (IsPedInAnyVehicle(player) and not IsThisModelABicycle(vehicle)) then
                DisplayRadar(false)
                SendNUIMessage({
                    action = HudShow,
                    type = 'SimpleHud',
                    armour = armour,
                    health = health,
                    food = PlayerData.metadata['hunger'],
                    thirst = PlayerData.metadata['thirst'],
                    voice = NetworkIsPlayerTalking(PlayerId()),
                    proxmity = status,
                    stress = stress,
                    stamina = oxygen,
                    breath = scaledOxygenLevel,
                })
            elseif IsPedInAnyVehicle(player) and not IsThisModelABicycle(vehicle) then
                local engineHealth = math.floor(GetVehicleEngineHealth(vehicle))
                local gearvehcile = GetVehicleCurrentGear(vehicle)
                local rpmlol = GetVehicleCurrentRpm(vehicle)
                DisplayRadar(true)
                SendNUIMessage({
                    action = HudShow,
                    type = 'CarHud',
                    armour = armour,
                    health = health,
                    food = PlayerData.metadata['hunger'],
                    thirst = PlayerData.metadata['thirst'],
                    voice = NetworkIsPlayerTalking(PlayerId()),
                    proxmity = status,
                    stress = stress,
                    stamina = oxygen,
                    seatbelt = seatbeltOn,
                    area = area,
                    harness = harness,
                    fuel = VehicleFuel,
                    vehspeed = VehicleSpeed,
                    enginerun = engineHealth,
                    gear = gearvehcile,
                    waydist = distance,
                    directions = direct,
                    rpm = rpmlol
                })
            end
        end
        Citizen.Wait(100)
    end
end

RegisterNetEvent('hud:client:LoadMap', function()
    Wait(500)
    -- Credit to Dalrae for the solve.
    local defaultAspectRatio = 1920 / 1080 -- Don't change this.
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX / resolutionY
    local minimapOffset = 0
    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.008
    end
    -- if _type == 'square' then
        RequestStreamedTextureDict('squaremap', false)
        while not HasStreamedTextureDictLoaded('squaremap') do
            Wait(150)
        end
        -- if Menu.isMapNotifChecked then
        --     QBCore.Functions.Notify(Lang:t('notify.load_square_map'))
        -- end
        SetMinimapClipType(0)
        AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'squaremap', 'radarmasksm')
        AddReplaceTexture('platform:/textures/graphics', 'radarmask1g', 'squaremap', 'radarmasksm')
        -- 0.0 = nav symbol and icons left
        -- 0.1638 = nav symbol and icons stretched
        -- 0.216 = nav symbol and icons raised up
        SetMinimapComponentPosition('minimap', 'L', 'B', 0.0 + minimapOffset, -0.047, 0.1638, 0.183)

        -- icons within map
        SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.0 + minimapOffset, 0.0, 0.128, 0.20)

        -- -0.01 = map pulled left
        -- 0.025 = map raised up
        -- 0.262 = map stretched
        -- 0.315 = map shorten
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01 + minimapOffset, 0.025, 0.262, 0.300)
        SetBlipAlpha(GetNorthRadarBlip(), 0)
        SetRadarBigmapEnabled(true, false)
        SetMinimapClipType(0)
        Wait(50)
        SetRadarBigmapEnabled(false, false)
        -- if Menu.isToggleMapBordersChecked then
        --     showCircleB = false
        --     showSquareB = true
        -- end
        Wait(1200)
        -- if Menu.isMapNotifChecked then
        --     QBCore.Functions.Notify(Lang:t('notify.loaded_square_map'))
        -- end
    -- elseif _type == 'circle' then
    --     RequestStreamedTextureDict('circlemap', false)
    --     if not HasStreamedTextureDictLoaded('circlemap') then
    --         Wait(150)
    --     end
    --     -- if Menu.isMapNotifChecked then
    --     --     QBCore.Functions.Notify(Lang:t('notify.load_circle_map'))
    --     -- end
    --     SetMinimapClipType(1)
    --     AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'circlemap', 'radarmasksm')
    --     AddReplaceTexture('platform:/textures/graphics', 'radarmask1g', 'circlemap', 'radarmasksm')
    --     -- -0.0100 = nav symbol and icons left
    --     -- 0.180 = nav symbol and icons stretched
    --     -- 0.258 = nav symbol and icons raised up
    --     SetMinimapComponentPosition('minimap', 'L', 'B', -0.0100 + minimapOffset, -0.030, 0.180, 0.258)

    --     -- icons within map
    --     SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.200 + minimapOffset, 0.0, 0.065, 0.20)

    --     -- -0.00 = map pulled left
    --     -- 0.015 = map raised up
    --     -- 0.252 = map stretched
    --     -- 0.338 = map shorten
    --     SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.00 + minimapOffset, 0.015, 0.252, 0.338)
    --     SetBlipAlpha(GetNorthRadarBlip(), 0)
    --     SetMinimapClipType(1)
    --     SetRadarBigmapEnabled(true, false)
    --     Wait(50)
    --     SetRadarBigmapEnabled(false, false)
    --     -- if Menu.isToggleMapBordersChecked then
    --     --     showSquareB = false
    --     --     showCircleB = true
    --     -- end
    --     Wait(1200)
    --     -- if Menu.isMapNotifChecked then
    --     --     QBCore.Functions.Notify(Lang:t('notify.loaded_circle_map'))
    --     -- end
    -- end
end)


LoadSettings = function ()
    local Settings = GetResourceKvpString('UIData')
    if Settings ~= nil then
        local data = json.decode(Settings)
        SendNUIMessage({
            type = 'Load',
            settings = data
        })
    end
    local defaultAspectRatio = 1920/1080 -- Don't change this.
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX/resolutionY
    local minimapOffset = 0
    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio-aspectRatio)/3.6)-0.008
    end
    RequestStreamedTextureDict("squaremap", false)
    if not HasStreamedTextureDictLoaded("squaremap") then
        Wait(150)
    end
    SetMinimapClipType(0)
    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
    AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")
    SetMinimapComponentPosition("minimap", "L", "B", 0.0 + minimapOffset, -0.047, 0.1638, 0.183)
    SetMinimapComponentPosition("minimap_mask", "L", "B", 0.0 + minimapOffset, 0.0, 0.128, 0.20)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01 + minimapOffset, 0.025, 0.262, 0.300)
    SetBlipAlpha(GetNorthRadarBlip(), 0)
    SetRadarBigmapEnabled(true, false)
    SetMinimapClipType(0)
    Wait(500)
    SetRadarBigmapEnabled(false, false)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(5000)
    getMapPosition()
    LoadSettings()
    loaded = true
    PlayerData = QBCore.Functions.GetPlayerData()
    HudStart()
end)  

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
   HudStart()
   HudShow = false
   loaded = false
   PlayerData = {}
   print("Unload")
   DisplayRadar(false)
end)  

function isPlayerLoaded()
    local playerPed = PlayerPedId()
    local playerExists = DoesEntityExist(playerPed)
    local playerActive = NetworkIsPlayerActive(PlayerId())

    -- Check if the player ped exists and the player is active in the network
    if playerExists and playerActive then
        local playerPos = GetEntityCoords(playerPed)
        -- Check if the player is at a valid position (not at the default spawn location)
        if playerPos.x ~= 0 or playerPos.y ~= 0 or playerPos.z ~= 0 then
            return true
        end
    end
    
    return false
end


AddEventHandler('onResourceStart', function(resourceName)
    if isPlayerLoaded() then
        TriggerEvent('hud:client:LoadMap')
        HudShow = true
        loaded = true
        HudStart()
        DisplayRadar(false)
    else
        TriggerEvent('hud:client:LoadMap')
        HudStart()
        HudShow = false
        loaded = false
        DisplayRadar(false)
    end
    
end)  


function getMapPosition()
	local minimap = {}
	local resX, resY = GetActiveScreenResolution()
	local aspectRatio = GetAspectRatio()
	local scaleX = 1/resX
	local scaleY = 1/resY
	local minimapRawX, minimapRawY
	SetScriptGfxAlign(string.byte('L'), string.byte('B'))
	if IsBigmapActive() then
		minimapRawX, minimapRawY = GetScriptGfxPosition(-0.003975, 0.022 + (-0.460416666))
		minimap.width = scaleX*(resX/(2.52*aspectRatio))
		minimap.height = scaleY*(resY/(2.3374))
	else
		minimapRawX, minimapRawY = GetScriptGfxPosition(-0.0045, 0.002 + (-0.188888))
		minimap.width = scaleX*(resX/(4*aspectRatio))
		minimap.height = scaleY*(resY/(5.674))
	end
	ResetScriptGfxAlign()
	minimap.leftX = minimapRawX
	minimap.rightX = minimapRawX+minimap.width
	minimap.topY = minimapRawY
	minimap.bottomY = minimapRawY+minimap.height
	minimap.X = minimapRawX+(minimap.width/2)
	minimap.Y = minimapRawY+(minimap.height/2)
	return minimap
end