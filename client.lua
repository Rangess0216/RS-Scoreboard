local isScoreboardOpen = false
local idDrawDistance = 20.0

local function DrawText3D(coords, text, color)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z + 1.0)
    
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        
        if color then
            SetTextColour(color.r, color.g, color.b, 255)
        else
            SetTextColour(255, 255, 255, 255)
        end
        
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function UpdateScoreboard()
    ESX.TriggerServerCallback('rs-scoreboard:getData', function(data)
        SendNUIMessage({
            action = "update",
            id = GetPlayerServerId(PlayerId()),
            players = data.players,
            police = data.police,
            ambulance = data.ambulance,
            mechanic = data.mechanic,
            doj = data.doj
        })
    end)
end

CreateThread(function()
    Wait(1000)
    SendNUIMessage({ action = "toggle", state = false })

    while true do
        Wait(0)
        
        if IsControlJustPressed(0, 20) then
            isScoreboardOpen = true
            UpdateScoreboard()
            SendNUIMessage({ action = "toggle", state = true })
        end

        if IsControlJustReleased(0, 20) then
            isScoreboardOpen = false
            SendNUIMessage({ action = "toggle", state = false })
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 500
        
        if isScoreboardOpen then
            sleep = 0
            
            local myPed = PlayerPedId()
            local myCoords = GetEntityCoords(myPed)
            local activePlayers = GetActivePlayers()
            local playerTags = GlobalState.PlayerTags or {}

            for _, player in ipairs(activePlayers) do
                local targetPed = GetPlayerPed(player)
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(myCoords - targetCoords)
                
                local showId = false

                if targetPed == myPed then
                    showId = true
                elseif distance < idDrawDistance then
                    if HasEntityClearLosToEntity(myPed, targetPed, 17) then
                        showId = true
                    end
                end

                if showId then
                    local serverId = GetPlayerServerId(player)
                    local isTalking = NetworkIsPlayerTalking(player)
                    
                    local idColor = {r = 255, g = 255, b = 255}
                    if isTalking then
                        idColor = {r = 0, g = 191, b = 255}
                    end

                    DrawText3D(targetCoords, "ID: " .. serverId, idColor)

                    if playerTags[serverId] then
                        local tagData = playerTags[serverId]
                        local tagCoords = vector3(targetCoords.x, targetCoords.y, targetCoords.z - 0.15)
                        DrawText3D(tagCoords, (tagData.color or "") .. tagData.label, nil)
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)