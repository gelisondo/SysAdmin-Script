#!/bin/bash
#Soy Root?
IDUSER=`id -u`
#Compara que no sea igual a cero.
if [ $IDUSER -ne 0 ];
then
	echo "Debe ser una cuenta administrador para ejecutar este script"
	exit
fi


#Resumen de los pasos a desarrollar
#2) Fail2band
#3) IDS/
#4) Check-mk - ok
#5) Grafana
#6) Data Time - NTP - ok
#7) sSMTP - ok
#8) Software de mantenimiento
    #Auto-upgrade  - ok
    #Limpieza de archivos temporales /tmp, /usr/tmp  - ok

#1) Firewall

#2) Fail2band

#3) IDS/


#4) Check-mk
#!!Esta Sección queda en un Script independiente, check_mk-install-plugins.sh!!!

#5) Grafana

#Actualizamos el sistema
apt-get update && apt-get -y upgrade
if [ $? -ne 0  ];
then
   echo -e " \033[37;41m Error al Actualizar \033[0m"
fi



#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#Herramientas para el sistema
function so-tools () {

apt install -y locate
if [ $? -ne 0  ];
then
   echo -e " \033[37;41m Error al Instalar la Herramienta locate  \033[0m"
fi


#Herramientas de Red
apt install -y iperf iftop nethogs  net-tools htop
if [ $? -ne 0  ];
then
   echo -e " \033[37;41m Error al Instalar Herramientas para el sistema \033[0m"
fi


## Mejora la compatibilidad de la maquina virtual.##
dpkg -l | grep "^ii  qemu-guest-agent" >> /dev/null
if [ $? -ne 0 ];
then
   apt install -y qemu-guest-agent
   if [ $? -ne 0  ];
   then
      echo -e " \033[37;41m Error al Instalar qemu-guest-agent \033[0m"
   fi

fi

}

####################
## Data Time - NTP##
####################
function ntp-time () {

echo ""
echo "Data Time - NTP"
echo ""

#Verificamos que el paquete ntp este instalado, la salida debe ser 0
dpkg -l | grep "^ii  ntp" >> /dev/null
if [ $? -eq 0 ];
then
	echo "configuraremos la hora utilizada por UTC-3 America/Montevideo"
	timedatectl set-timezone "America/Montevideo"
        /etc/init.d/ntpsec restart
	timedatectl
else
	echo "Instalamos el cliente NTP"
	echo ""
	apt-get install -y ntp
	echo ""
	echo "configuraremos la hora utilizada por UTC-3 America/Montevideo"
	timedatectl set-timezone "America/Montevideo"
         /etc/init.d/ntpsec restart
	timedatectl
fi
}

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
###########
## sSMTP ##
###########

function notificacion-ssmtp () {

echo ""
echo " Configuramos Notificaciones por sSMTP"
echo ""

dpkg -l | grep "^ii  ssmtp" >> /dev/null
if [ $? -eq 0 ];
then
		echo "Configuramos la cuenta notificador@tudominio.lan para las notificaciones"
		sleep 1

		BUSON="notificador@tudominio.lan"
		MAILSERVER="mail.tudominio.lan"
		PASSWORD="TuSuperContraseñaX"

		#Si el archivo existe, eliminamos toda la configuración antigua pertinente.
		if [ -f /etc/ssmtp/ssmtp.conf ];
		then
				sed -i '/mailhub=/d' /etc/ssmtp/ssmtp.conf
				sed -i '/@enba.edu.uy/d' /etc/ssmtp/ssmtp.conf
				sed -i '/AuthUser=/d' /etc/ssmtp/ssmtp.conf
				sed -i '/AuthPass=/d' /etc/ssmtp/ssmtp.conf
				sed -i '/UseTLS=YES/d' /etc/ssmtp/ssmtp.conf
				sed -i '/UseSTARTTLS=YES/d' /etc/ssmtp/ssmtp.conf
				sed -i '/FromLineOverride=YES/d' /etc/ssmtp/ssmtp.conf
		fi

		echo "configuramos sSMTP"
		sed -i "s/mailhub=mail/mailhub=$MAILSERVER/g" /etc/ssmtp/ssmtp.conf
		sed -i "s/postmaster/$BUSON/g" /etc/ssmtp/ssmtp.conf
		echo "AuthUser=$BUSON" >> /etc/ssmtp/ssmtp.conf
		echo "AuthPass=$PASSWORD" >> /etc/ssmtp/ssmtp.conf
		echo "UseTLS=YES" >> /etc/ssmtp/ssmtp.conf
		echo "UseSTARTTLS=YES" >> /etc/ssmtp/ssmtp.conf
		echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf

		echo "Configuramos las Alias"
		#Solo Root y systecadmin pueden enviar e-mails desde la consola.
		if [ -f /etc/ssmtp/revaliases ];
		then
				rm /etc/ssmtp/revaliases
				touch /etc/ssmtp/revaliases
		fi
		echo "root:$BUSON:$MAILSERVER:587" >> /etc/ssmtp/revaliases
		echo "systecadmin:$BUSON:$MAILSERVER:587" >> /etc/ssmtp/revaliases
else

 # Se instalaran el Software
 apt-get install -y ssmtp
 if [ $? -ne 0  ];
 then
   echo -e " \033[37;41m Error la instalar SSMTP \033[0m"
 fi


			echo "Configuramos la cuenta notificador@tudominio.lan para las notificaciones"
			sleep 1
		    BUSON="notificador@tudominio.lan"
		    MAILSERVER="mail.tudominio.lan"
		    PASSWORD="TuSuperContraseñaX"

			if [ -f /etc/ssmtp/ssmtp.conf ];
		  then
				  sed -i '/mailhub=/d' /etc/ssmtp/ssmtp.conf
					sed -i '/@enba.edu.uy/d' /etc/ssmtp/ssmtp.conf
					sed -i '/AuthUser=/d' /etc/ssmtp/ssmtp.conf
					sed -i '/AuthPass=/d' /etc/ssmtp/ssmtp.conf
					sed -i '/UseTLS=YES/d' /etc/ssmtp/ssmtp.conf
					sed -i '/UseSTARTTLS=YES/d' /etc/ssmtp/ssmtp.conf
					sed -i '/FromLineOverride=YES/d' /etc/ssmtp/ssmtp.conf
			fi

			echo "configuramos sSMTP"
			#echo "root=tecnicos@eumus.edu.uy" > /etc/ssmtp/ssmtp.conf
			sed -i "s/mailhub=mail/mailhub=$MAILSERVER/g" /etc/ssmtp/ssmtp.conf
			sed -i "s/postmaster/$BUSON/g" /etc/ssmtp/ssmtp.conf
			echo "AuthUser=$BUSON" >> /etc/ssmtp/ssmtp.conf
			echo "AuthPass=$PASSWORD" >> /etc/ssmtp/ssmtp.conf
			echo "UseTLS=YES" >> /etc/ssmtp/ssmtp.conf
			echo "UseSTARTTLS=YES" >> /etc/ssmtp/ssmtp.conf
			echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf

			echo "Configuramos las Alias"
			#Solo Root y systecadmin pueden enviar e-mails desde la consola.
			if [ -f /etc/ssmtp/revaliases ];
			then
					rm /etc/ssmtp/revaliases
					touch /etc/ssmtp/revaliases
			fi
			echo "root:$BUSON:$MAILSERVER:587" >> /etc/ssmtp/revaliases
			echo "systecadmin:$BUSON:$MAILSERVER:587" >> /etc/ssmtp/revaliases
fi
}

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
##############################
## Sección de mantenimiento.##
##############################
function auto-upgrade-papa () {

## Auto-upgrade ##
echo ""
echo "Configuramos Auto-Upgrade"
echo ""

#https://libre-software.net/ubuntu-automatic-updates/
#Verificamos si se encuentra instalado el paquete necesario
 dpkg -l | grep "^ii  unattended-upgrades"
if [ $? -eq 0 ];
then

if [ -f /etc/apt/apt.conf.d/99unattended-upgrades ];
then
		rm /etc/apt/apt.conf.d/99unattended-upgrades
fi
#Configuramos el Archivo para automatizar las actualizaciones.
touch /etc/apt/apt.conf.d/99unattended-upgrades
echo ' Unattended-Upgrade::Allowed-Origins { ' >> /etc/apt/apt.conf.d/99unattended-upgrades
echo '  "${distro_id}:${distro_codename}-updates";' >> /etc/apt/apt.conf.d/99unattended-upgrades
echo '  "${distro_id}:${distro_codename}-proposed";' >> /etc/apt/apt.conf.d/99unattended-upgrades
echo '  "${distro_id}:${distro_codename}-backports";' >> /etc/apt/apt.conf.d/99unattended-upgrades
echo ' }; ' >> /etc/apt/apt.conf.d/99unattended-upgrades
echo ' Unattended-Upgrade::AutoFixInterruptedDpkg "true"; ' >> /etc/apt/apt.conf.d/99unattended-upgrades
echo ' Unattended-Upgrade::MinimalSteps "true"; ' >> /etc/apt/apt.conf.d/99unattended-upgrades
echo ' Unattended-Upgrade::Remove-Unused-Kernel-Packages "true"; ' >> /etc/apt/apt.conf.d/99unattended-upgrades
echo ' Unattended-Upgrade::Remove-New-Unused-Dependencies "true"; ' >> /etc/apt/apt.conf.d/99unattended-upgrades
echo ' Unattended-Upgrade::Remove-Unused-Dependencies "true"; ' >> /etc/apt/apt.conf.d/99unattended-upgrades
echo ' Unattended-Upgrade::Automatic-Reboot-Time "05:00"; ' >> /etc/apt/apt.conf.d/99unattended-upgrades

else
	#instalamos el paquete
	apt-get install -y unattended-upgrades
	if [ $? -ne 0  ];
	then
	   echo -e " \033[37;41m Error al Transferir \033[0m"
	fi


	if [ -f /etc/apt/apt.conf.d/99unattended-upgrades ];
	then
			rm /etc/apt/apt.conf.d/99unattended-upgrades
	fi
	#Configuramos el Archivo para automatizar las actualizaciones.
	touch /etc/apt/apt.conf.d/99unattended-upgrades
  echo ' Unattended-Upgrade::Allowed-Origins { ' >> /etc/apt/apt.conf.d/99unattended-upgrades
  echo '  "${distro_id}:${distro_codename}-updates";' >> /etc/apt/apt.conf.d/99unattended-upgrades
  echo '  "${distro_id}:${distro_codename}-proposed";' >> /etc/apt/apt.conf.d/99unattended-upgrades
  echo '  "${distro_id}:${distro_codename}-backports";' >> /etc/apt/apt.conf.d/99unattended-upgrades
  echo ' }; ' >> /etc/apt/apt.conf.d/99unattended-upgrades
  echo ' Unattended-Upgrade::AutoFixInterruptedDpkg "true"; ' >> /etc/apt/apt.conf.d/99unattended-upgrades
  echo ' Unattended-Upgrade::MinimalSteps "true"; ' >> /etc/apt/apt.conf.d/99unattended-upgrades
  echo ' Unattended-Upgrade::Remove-Unused-Kernel-Packages "true"; ' >> /etc/apt/apt.conf.d/99unattended-upgrades
  echo ' Unattended-Upgrade::Remove-New-Unused-Dependencies "true"; ' >> /etc/apt/apt.conf.d/99unattended-upgrades
  echo ' Unattended-Upgrade::Remove-Unused-Dependencies "true"; ' >> /etc/apt/apt.conf.d/99unattended-upgrades
  echo ' Unattended-Upgrade::Automatic-Reboot-Time "05:00"; ' >> /etc/apt/apt.conf.d/99unattended-upgrades
fi
}
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
### Configuramos una limpieza de los paquetes deb descargados, ya instalados ###

function limpia-paquetes () {
#Una vez cada semana, a las 6 y 52 de la mañana.
grep "apt-get" /etc/crontab
if [ $? -ne 0 ];
then
			echo "52 6    * * 7     apt-get -y clean" >> /etc/crontab
fi
}
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
### Se instalar software para Limpiar /tmp /usr/tmp, analizando el tiempo de uso o si es un socket ###
#Tras una acutalización pueda ser que nos sobre escriba le archivo de configuración, una alternativa puede ser utilziar cron
echo "Se instalar software para Limpiar /tmp /usr/tmp, analizando el tiempo de uso o si es un socket"
dpkg -l | grep "^ii  tmpreaper"
if [ $? -eq 0];
then
	apt-get install -y  tmpreaper
	if [ $? -ne 0  ];
	then
	   echo -e " \033[37;41m Error al instalar el limpiador de temporales /tmp y /usr/tmp  \033[0m"
	fi

	sed -i '/SHOWWARNING=true/d' /etc/tmpreaper.conf
	sed -i '/TMPREAPER_DIRS=/d' /etc/tmpreaper.conf
	echo "TMPREAPER_DIRS='/tmp/. /var/tmp/.'" >> /etc/tmpreaper.conf
fi

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Buscamos RootKit y Virus en el sistema.
#https://sourceforge.net/p/rkhunter/wiki/index/
#https://www.tecmint.com/install-rootkit-hunter-scan-for-rootkits-backdoors-in-linux/
function anti-rootkit () {
 dpkg -l | grep "^ii  rkhunter"
 if [ $? -eq 0];
 then
	 #Configuración para poder actualizar la base de datos de rkhunter
	 sed -i '/WEB_CMD="/bin/false"/d' /etc/rkhunter.conf
	 echo  "WEB_CMD=curl" >> /etc/rkhunter.conf
	 sed -i 's/UPDATE_MIRRORS=0/UPDATE_MIRRORS=1/g' /etc/rkhunter.conf
	 sed -i 's/MIRRORS_MODE=1/MIRRORS_MODE=0/g' /etc/rkhunter.conf

	 #Eliminamos  Script post instalación de rkhunter para cron.daily
         rm /etc/cron.daily/rkhunter

	 #Movemos el script de scaneo y actualización a /etc/cron.daily/
	 if [ -f rkhunter-daily.sh ];
	 then
			 if [ -f /etc/cron.daily/rkhunter-daily.sh ];
			 then
					 echo "Ok - El archivo existe"
			 else
					 chmod 750 rkhunter-daily.sh
					 mv rkhunter-daily.sh /etc/cron.daily/
			 fi
	fi

 else
	 	#Para la busqueda de rootkit utilizaremos rkhunter, tener en cuenta que esto instala postfix como dependencia.
		apt-get install -y  --no-install-recommends mailutils
		if [ $? -ne 0  ];
		then
		   echo -e " \033[37;41m Error al instalar Utilidades de e-mail - mailutils. \033[0m"
		fi

		apt-get install -y --no-install-recommends rkhunter
		if [ $? -ne 0  ];
		then
			   echo -e " \033[37;41m Error al instalar RkHunter - Casador de Root Kit \033[0m"
		fi


		#Editar archivos de configuración.
		#Configuración para poder actualizar la base de datos de rkhunter
		sed -i '/WEB_CMD="/bin/false"/d' /etc/rkhunter.conf
		echo  "WEB_CMD=curl" >> /etc/rkhunter.conf
		sed -i 's/UPDATE_MIRRORS=0/UPDATE_MIRRORS=1/g' /etc/rkhunter.conf
		sed -i 's/MIRRORS_MODE=1/MIRRORS_MODE=0/g' /etc/rkhunter.conf

		#Eliminamos  Script post instalación de rkhunter para cron.daily
		rm /etc/cron.daily/rkhunter

		#Movemos el script de scaneo y actualización a /etc/cron.daily/
		if [ -f rkhunter-daily.sh ];
		then
				if [ -f /etc/cron.daily/rkhunter-daily.sh ];
			  then
						echo "Ok - El archivo existe"
				else
						chmod 750 rkhunter-daily.sh
						mv rkhunter-daily.sh /etc/cron.daily/
				fi
    fi


fi
}

####################################
# Llamamos a funciones expecificas #
####################################
#Si verificamos que no sea el servidor Guacamole, pues es muy sensible a los cambios de tiempos ya configurados po su ToTP
if [ ! -d /etc/guacamole ];
then
  ntp-time
else
  echo "Es Guacamole - No instalar"
fi

#Verificamos si es el servidor de Mailman, al cual no se le debe aplicar esta configuración
dpkg -l | grep "^ii  mailman"
if [ $? -ne 0 ];
then

	HOST=`hostname`
	if [ ! WServerP7 = $HOST ];
	then
        	echo "Instalamos SSMTp"
		notificacion-ssmtp
	fi
fi

auto-upgrade-papa
limpia-paquetes
anti-rootkit
so-tools
