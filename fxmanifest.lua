fx_version 'adamant'

game 'gta5'

description 'XP Ranking System (non-ESX version)'

author 'Karl Saunders'

version '1.4.1'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'locale.lua',
    'locales/en.lua',
    'config.lua',
    'utils.lua',
    'server/main.lua'
}

client_scripts {
    'locale.lua',
    'locales/en.lua',
    'config.lua',
    'utils.lua',
    'client/main.lua',
    'demo.lua' -- remove if not required
}

ui_page 'ui/ui.html'

files {
    'ui/ui.html',
    'ui/fonts/ChaletComprimeCologneSixty.ttf',
    'ui/css/app.css',
    'ui/js/class.xpm.js',
    'ui/js/class.leaderboard.js',
    'ui/js/app.js'
}

export 'XPM_SetInitial'
export 'XPM_Add'
export 'XPM_Remove'
export 'XPM_SetRank'

export 'XPM_GetXP'
export 'XPM_GetRank'
export 'XPM_GetXPToNextRank'
export 'XPM_GetXPToRank'
export 'XPM_GetMaxXP'
export 'XPM_GetMaxRank'

export 'XPM_ShowUI'
export 'XPM_HideUI'