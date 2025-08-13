#!/bin/bash
#Distro Ubuntu - 22.04 2024
#Version 2.7
if test -z $1
then 
 echo "Es necesario ingrasar el TAG para el inventario, ej: BA-PR-20"
 exit 0
fi

#Restablecer la contraseña de root
iroot=`id -u`
echo $iroot
if test $iroot -eq 0
then
        echo "OK Soy Root"
	echo "Quieres establecer una contraseña para root (SI | NO)"
	read PROOT
	case $PROOT in
	SI) 
		passwd root
	;;
	NO)
		echo "La clave para el usuario root no fue establecida"
	;;
	*)
		echo "Solo es permitido dos confirmaciones (SI | NO)"
	;;
	esac
	
else
        echo ":( No soy Root"
        exit 0
fi

echo ""
echo "PUrgamos Paquetes ignecesarios."
apt-get -y purge modemmanager 
apt-get autoremov --purge -y

echo ""
echo "Acutiliazamos"
apt-get -y update && apt-get -y upgrade
apt-get install -y --install-recommends linux-generic-hwe-22.04 gdebi-core 

echo "Instalación de hard info"
apt-get install -y hardinfo

echo "Instalando Zoom Meet"
wget https://zoom.us/client/latest/zoom_amd64.deb
gdebi -n zoom_amd64.deb

echo "instalación de sofware manipulación de imagenes y video"
apt-get install -y gimp krita digikam darktable inkscapeh kdenlive



####################
#   adicionales-c-
####################
echo ""
echo " Aceptar el EULA para mscorefonts (incluido en el meta kubuntu-restricted-extras)"
echo " Le ingresamos estos parametros al debconf-set-selections, para que acepte cuendo se encuentra con licencias EULA de microsoft."
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

echo ""
echo "Habilitamos las fuentes en el sistema."
fc-cache -f -v

echo ""
echo "Locales Idiomas."
apt-get install -y firefox-locale-es thunderbird-locale-es-ar libreoffice-l10n-es  

echo ""
echo "Soporte NTP"
apt-get install -y ntp  libopts25

echo ""
echo "Instalación de paquetes Múltimedia"
apt install -y vlc flac ffmpeg 

echo ""
echo "Instalamos y configuramos fusioninventory"
apt-get install  -y fusioninventory-agent
echo "server = https://glpi.local.domain.lan/plugins/fusioninventory/" >> /etc/fusioninventory/agent.cfg
sed -i 's/tag\ =/ /g' /etc/fusioninventory/agent.cfg
echo "tag = $1" >> /etc/fusioninventory/agent.cfg

#Se le agrego la sepción (Cambio de host + Número de serie)
#Assign existing hostname to $hostn
hostn=$(cat /etc/hostname)

#Display existing hostname
echo "Host actual $hostn"

#Ask for new hostname $newhost
echo "Ingrese nuevo host: "
read newhost

#change hostname in /etc/hosts & /etc/hostname
sudo sed -i "s/$hostn/$newhost/g" /etc/hosts
sudo sed -i "s/$hostn/$newhost/g" /etc/hostname

#display new hostname
echo "Nuevo nombre de usuario: $(tput setaf 6)$newhost$(tput sgr0)"


echo "$(tput setaf 1)Recuerde que es necesario reiniciar el sistema para que el cambio de host sea efectivo$(tput sgr0)" 

while true; do
    read -p "¿Desea reiniciar? y/n: " yn
    case $yn in
        [Yy]* ) reboot   
		break;;
		
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done



