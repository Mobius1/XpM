fx_version 'adamant'

game 'gta5'

description 'XP Ranking System (non-ESX version)'

author 'Karl Saunders'

version '1.2.1'

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
    'client/main.lua'
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/fonts/ChaletComprimeCologneSixty.ttf',
    'html/css/app.css',
    'html/js/class.xpm.js',
    'html/js/class.leaderboard.js',
    'html/js/app.js'
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