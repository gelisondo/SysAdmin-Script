#!/bin/bash

echo -n "Cambiando la Mac WIFI"
ifconfig wlp2s0 down
macchanger -a wlp2s0
ifconfig wlp2s0 up

echo -n "Cambiando la MAC Ethernet"
echo -n "Bajando la interface enp4s0"
ifconfig enp4s0 down
echo -n "Cambiando la MAC"
macchanger -a enp4s0
echo -n "Habilitando la interfaz"
ifconfig enp4s0 up
