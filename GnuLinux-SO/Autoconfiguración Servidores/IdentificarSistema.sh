#!/bin/bash


#Verificamos si el es DEBIAN/UBUNTU
function whatso () {
if   [ -e /etc/lsb-release ]; then
    grep _ID=Ubuntu  /etc/lsb-release > /dev/null
    if [ $? -eq 0 ];
     then
        SO="UBUNTU"
    fi
elif [ -e /etc/debian_version ] ; then
        SO="DEBIAN"

fi
