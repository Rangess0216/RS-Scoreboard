fx_version 'cerulean'
game 'gta5'

Author 'Rangess0216'
description 'Scoreboard v2'
version '1.1.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

client_script 'client.lua'
server_script 'server.lua'