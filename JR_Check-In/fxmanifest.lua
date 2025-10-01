fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'JRScripts'
description 'ESX Simple Check-in System using ox_lib and ox_target'
version '1.0.0'

shared_script '@ox_lib/init.lua'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    '@es_extended/imports.lua',
    'config.lua',
    'server.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'es_extended'
}
