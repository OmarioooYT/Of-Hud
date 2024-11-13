fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'qb-hud'
version '2.2.0'

client_script 'C/*.lua'
server_script 'S/*.lua'
shared_scripts {'config.lua'}


ui_page 'UI/index.html'
files {
    'UI/responsive.css',
    'UI/*.html',
    'UI/*.css',
    'UI/*.js',
    'UI/*.svg',
    'UI/*.png'
}