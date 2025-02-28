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
local currentLobby = 0
local currentLobbyCount = 0

RegisterCommand(Config.Command, function()
    openLobbyContextMenu()
end, false)

function openLobbyContextMenu()
    TriggerServerEvent("lf_nuværendelobby")
    Wait(100)
    showLobbyMenu()
end

RegisterNetEvent("lf_sendnuværendelobby", function(aktuellobby, count)
    if not aktuellobby then
        aktuellobby = locale["ingen_lobby"]
    end

    currentLobby = aktuellobby
    currentLobbyCount = count
end)

local Watermark = {
    {label = 'Lavet af', value = 'LF Scripts'},
    {label = 'Discord', value = 'discord.gg/f595VxygMt'}
}

local function getWatermark()
    return Config.Watermark and Watermark or nil
end

function showLobbyMenu()
    lib.registerContext({
        id = 'lf_lobby',
        title = locale["lobby_menu"],
        options = {
            {
                title = locale["aktuellobby"] and locale["aktuellobby"]:format(tostring(currentLobby)) or "Lobby: " .. tostring(currentLobby),
                description = locale["aktuel_lobby_desc"]:format(tostring(currentLobbyCount)),
                icon = 'hashtag',
                metadata = getWatermark(),
                readOnly = true,
                progress = 100,
                colorScheme = 'red'
            },
            {
                title = locale["skift_lobby_title"],
                description = locale["skift_lobby_desc"],
                icon = 'repeat',
                onSelect = function()
                    local input = lib.inputDialog(locale["skift_lobby_title"], {
                        {type = 'number', label = locale["indtast_lobbynummer"], placeholder = locale["indtast_lobbyplaceholder"], icon = 'info'}
                    })

                    if input then
                        local lobbyId = tonumber(input[1])
                        if lobbyId and lobbyId >= 0 then
                            TriggerServerEvent("lf_spillerlobby", lobbyId)
                        else
                            lib.notify({
                                title = locale["fejl"],
                                description = locale["ugyldigt_lobbynummer"],
                                type = 'error',
                                showDuration = false,
                                position = 'center-right',
                            })
                        end
                    end
                end,
            },
            {
                title = locale["reset_lobby_title"],
                description = locale["reset_lobby_desc"],
                icon = 'power-off',
                iconColor = '#FF3D3D',
                onSelect = function()
                    TriggerServerEvent("lf_resetlobby")
                end,
            },
        },
    })
    lib.showContext("lf_lobby")
end


RegisterNetEvent("lf_skiftnotify", function(aktuellobby)
    lib.notify({
        title = locale["skift_lobby"],
        description = locale["skift_lobby_bedsked"]:format(tostring(aktuellobby)),
        type = 'info',
        duration = Config.Notify.duration,
        showDuration = Config.Notify.showDuration,
        position = Config.Notify.position,
    })
  end)

RegisterNetEvent("lf_resetnotify", function(aktuellobby)
  lib.notify({
      title = locale["lobby_reset"],
      description = locale["lobby_reset_bedsked"]:format(tostring(aktuellobby)),
      type = 'info',
      duration = Config.Notify.duration,
      showDuration = Config.Notify.showDuration,
      position = Config.Notify.position,
  })
end)