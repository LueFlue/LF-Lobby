fx_version 'cerulean'
lua54 'yes'
game 'gta5'

author 'LF Scripts - https://discord.gg/f595VxygMt'
description 'Lobby Script af LF Scripts'
version '1.0.0'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

shared_scripts {
    'locale/*.lua',
    'config.lua',
    '@ox_lib/init.lua'
}

dependencies {
    'ox_lib'
}