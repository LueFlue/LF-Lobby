-------------------------------------------------------------------------
--          _      ______    _____           _       _                 --
--         | |    |  ____|  / ____|         (_)     | |                --
--         | |    | |__    | (___   ___ _ __ _ _ __ | |_ ___           --
--         | |    |  __|    \___ \ / __| '__| | '_ \| __/ __|          --
--         | |____| |       ____) | (__| |  | | |_) | |_\__ \          --
--         |______|_|      |_____/ \___|_|  |_| .__/ \__|___/          --
--                                            | |                      --
--                                            |_|                      --
------------------------------------------------------------------------- 

local function loadLocale(locale)
    local filePath = "locale/" .. locale .. ".lua"
    local fileContent = LoadResourceFile(GetCurrentResourceName(), filePath)

    if not fileContent then
        print("^1[FEJL] Locale ikke fundet: " .. filePath .. "^7")
        return nil
    else
        print("^2[LF SCRIPTS] Locale loaded: " .. filePath .. "^7")
    end

    local localeData, errorMessage = load(fileContent, "locale data")

    if not localeData then
        print("^1[FEJL] Kunne ikke load locale data: " .. errorMessage .. "^7")
        return nil
    end

    return localeData()
end

locale = loadLocale(Config.Locale or "da") or {}

if not locale then
    print("^1[FEJL] Kunne ikke load locale. Bruger standard locale^7")
end

----------------------------------------------------------------------------------------
local playerLobbies = {}
local lobbyCounts = {}

local function UpdateLobbySpillere(lobbyId)
    local count = lobbyCounts[lobbyId] or 0

    for player, lobby in pairs(playerLobbies) do
        if lobby == lobbyId then
            TriggerClientEvent("lf_update_lobby_count", player, lobbyId, count)
        end
    end
end

RegisterNetEvent("lf_nuværendelobby", function()
    local source = source
    local aktuellobby = playerLobbies[source] or 0
    local count = lobbyCounts[aktuellobby] or 0
    TriggerClientEvent("lf_sendnuværendelobby", source, aktuellobby, count)
end)

RegisterNetEvent("lf_spillerlobby", function(lobbyId)
    local source = source
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source))

    lobbyId = tonumber(lobbyId) or 0
    local oldLobby = playerLobbies[source] or 0

    if lobbyCounts[oldLobby] then
        lobbyCounts[oldLobby] = math.max(0, lobbyCounts[oldLobby] - 1)
        UpdateLobbySpillere(oldLobby)
    end

    playerLobbies[source] = lobbyId
    SetPlayerRoutingBucket(source, lobbyId)

    lobbyCounts[lobbyId] = (lobbyCounts[lobbyId] or 0) + 1

    if vehicle ~= 0 then
        SetEntityRoutingBucket(vehicle, lobbyId)
    end

    TriggerClientEvent("lf_skiftnotify", source, lobbyId)
    UpdateLobbySpillere(lobbyId)
end)

RegisterNetEvent("lf_resetlobby", function()
    local source = source
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source))
    local oldLobby = playerLobbies[source] or 0

    if lobbyCounts[oldLobby] then
        lobbyCounts[oldLobby] = math.max(0, lobbyCounts[oldLobby] - 1)
        UpdateLobbySpillere(oldLobby)
    end

    playerLobbies[source] = 0
    SetPlayerRoutingBucket(source, 0)

    lobbyCounts[0] = (lobbyCounts[0] or 0) + 1

    if vehicle ~= 0 then
        SetEntityRoutingBucket(vehicle, 0)
    end

    UpdateLobbySpillere(0)

    TriggerClientEvent("lf_resetnotify", source, 0)
end)

AddEventHandler("playerDropped", function()
    local source = source
    local oldLobby = playerLobbies[source] or 0

    if lobbyCounts[oldLobby] then
        lobbyCounts[oldLobby] = math.max(0, lobbyCounts[oldLobby] - 1)
        UpdateLobbySpillere(oldLobby)
    end

    playerLobbies[source] = nil
end)

AddEventHandler("playerJoining", function(source)
    playerLobbies[source] = 0
    lobbyCounts[0] = (lobbyCounts[0] or 0) + 1
    SetPlayerRoutingBucket(source, 0)
    TriggerClientEvent("lf_sendnuværendelobby", source, 0, lobbyCounts[0])
end)
