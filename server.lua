ESX = exports["es_extended"]:getSharedObject()

local function GetDiscordRoles(userDiscordId)
    local endpoint = ("https://discord.com/api/v10/guilds/%s/members/%s"):format(Config.GuildId, userDiscordId)
    local memberData = nil
    
    PerformHttpRequest(endpoint, function(errorCode, resultData, resultHeaders)
        if errorCode == 200 then
            memberData = json.decode(resultData)
        end
    end, "GET", "", {["Authorization"] = "Bot " .. Config.DiscordBotToken})

    local timeout = 0
    while memberData == nil and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    return memberData and memberData.roles or {}
end

local function GetDiscordId(source)
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.match(id, "discord:") then
            return string.gsub(id, "discord:", "")
        end
    end
    return nil
end

local function AssignTag(source)
    local discordId = GetDiscordId(source)
    local myTag = nil

    if discordId then
        local userRoles = GetDiscordRoles(discordId)
        if userRoles then
            for _, tagConfig in ipairs(Config.Tags) do
                for _, role in ipairs(userRoles) do
                    if tostring(role) == tostring(tagConfig.roleId) then
                        myTag = tagConfig
                        goto found
                    end
                end
            end
        end
    end

    ::found::
    
    if not myTag then
        for _, tagConfig in ipairs(Config.Tags) do
            if tagConfig.roleId == "default" then
                myTag = tagConfig
                break
            end
        end
    end

    if myTag then
        local currentTags = GlobalState.PlayerTags or {}
        currentTags[source] = myTag
        GlobalState.PlayerTags = currentTags
    end
end

AddEventHandler('esx:playerLoaded', function(source)
    AssignTag(source)
end)

CreateThread(function()
    Wait(1000)
    local xPlayers = ESX.GetExtendedPlayers()
    for _, xPlayer in pairs(xPlayers) do
        AssignTag(xPlayer.source)
    end
end)

RegisterCommand('streamer', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    local discordId = GetDiscordId(source)

    if not discordId then
        if xPlayer then xPlayer.showNotification("~r~Brak wykrytego Discorda.") end
        return
    end

    local userRoles = GetDiscordRoles(discordId)
    local hasPermission = false

    if userRoles then
        for _, role in ipairs(userRoles) do
            if tostring(role) == tostring(Config.StreamerRoleId) then
                hasPermission = true
                break
            end
        end
    end

    if not hasPermission then
        if xPlayer then xPlayer.showNotification("~r~Nie posiadasz uprawnień do tej komendy (Brak rangi Streamer).") end
        return
    end

    local currentTags = GlobalState.PlayerTags or {}
    local playerTag = currentTags[source]

    if playerTag and playerTag.label == "Streamer" then
        AssignTag(source) -- Przywróć starą rangę
        if xPlayer then xPlayer.showNotification("Tryb Streamera: ~r~Wyłączony") end
    else
        currentTags[source] = {
            label = "Streamer",
            color = "~p~"
        }
        GlobalState.PlayerTags = currentTags
        if xPlayer then xPlayer.showNotification("Tryb Streamera: ~g~Włączony") end
    end
end, false)

ESX.RegisterServerCallback('rs-scoreboard:getData', function(source, cb)
    local xPlayers = ESX.GetExtendedPlayers()
    local xSourcePlayer = ESX.GetPlayerFromId(source)
    
    local policeCount = 0
    local ambulanceCount = 0
    local mechanicCount = 0
    local dojCount = 0
    local totalPlayers = #xPlayers
    
    local myName = "Nieznajomy"
    local myJobLabel = "Brak Pracy"

    if xSourcePlayer then
        myName = xSourcePlayer.getName()
        if xSourcePlayer.job and xSourcePlayer.job.label then
            myJobLabel = xSourcePlayer.job.label
        end
    end

    for _, xPlayer in pairs(xPlayers) do
        local job = xPlayer.job.name
        
        if job == 'police' then policeCount = policeCount + 1
        elseif job == 'ambulance' then ambulanceCount = ambulanceCount + 1
        elseif job == 'mechanic' then mechanicCount = mechanicCount + 1
        elseif job == 'doj' then dojCount = dojCount + 1
        end
    end

    cb({
        players = totalPlayers,
        police = policeCount,
        ambulance = ambulanceCount,
        mechanic = mechanicCount,
        doj = dojCount,
        name = myName, 
        jobLabel = myJobLabel
    })
end)