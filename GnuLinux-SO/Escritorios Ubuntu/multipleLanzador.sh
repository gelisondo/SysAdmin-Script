#! /bin/bash

function lanzar()
{
#Aplicaciones 
firefox --geometry  1080x1920+3520+60 &
firefox --geometry  1600x900+0+0 &
firefox --geometry  1920x1080+1600+900 &

thunderbird --geometry 1920x1080+1600+900 &
#terminator --geometry  1080x1920+3520+60 &
terminator --geometry  1600x900+0+0 &

env BAMF_DESKTOP_FILE_HINT=/var/lib/snapd/desktop/applications/codium_codium.desktop /snap/bin/codium --force-user-en &
keepassx &

}


lanzar