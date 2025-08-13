#!/bin/bash
#Soy Root?
IDUSER=`id -u`
#Compara que no sea igual a cero.
if [ $IDUSER -ne 0 ];
then
	echo "Debe ser una cuenta administrador para ejecutar este script"
	exit
fi

#Instalamos y configuramos plug-ins Check_mk agets:
#Variables
SERVIDOR1="192.168.0.34"
SERVIDOR2="192.168.0.107"

SITIO="pocitos"
PATHPLUGINS="/usr/lib/check_mk_agent/plugins"


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
}

#Instlación del paquete check_mk_agent
function ins-check_mk_agent () {
  #statements
  #Deberiamos convinarlo con la funcion WhatSO, y si es Debian/Ubuntu correr las lineas siguientes.!!!! NOTA!!!!!
  #Instalamos XinetD para correr el agente como Daemon

  dpkg -l | grep "^ii  check-mk-agent" >> /dev/null
  if [ $? -eq 0 ];
   then
	echo "Check-mk-Agent ya instalado"
        #Desabilitamos el socket por systemd
	systemctl disable check_mk.socket

	#Verificamos si tenemos la versión 2.0.0p
	dpkg -l | grep "^ii  check-mk-agent" |  grep 2.0.0p >> /dev/null
	if [ $? -ne 0 ];
	then
		#Purgamos la versión actual
		apt-get purge -y check-mk-agent

		#Actualizamos el Sistema y Instalamos Xinetd
		apt-get update && apt-get upgrade -y && apt-get install -y xinetd

		#Descargamos e instalamos check-mk-agent
		wget $SERVIDOR1/$SITIO/check_mk/agents/check-mk-agent_2.0.0p3-1_all.deb
		dpkg -i check-mk-agent_2.0.0p3-1_all.deb
		if [ $? -eq 0 ];
		then
			 echo "La instalación se realizon con exito"
		fi
	fi

   else

    #Actualizamos y instalamos XinetD
    apt-get update && apt-get upgrade -y && apt-get install -y xinetd

    #Descargamos e instalamos check-mk-agent
    wget $SERVIDOR1/$SITIO/check_mk/agents/check-mk-agent_2.0.0p3-1_all.deb
    dpkg -i check-mk-agent_2.0.0p3-1_all.deb
    if [ $? -eq 0 ];
    then
      echo "La instalación se realizon con exito"
    fi

  fi

  #Verificamos si existe el archivo check_mk
  #Si existe lo eliminamos para pasarle la nueva configuracion
  if [ -f /etc/xinetd.d/check_mk ];
  then
	rm /etc/xinetd.d/check_mk
  fi

  #Configuramos XinetD
  #Archivos de configuración
  echo "" /etc/xinetd.d/check_mk
  echo "service check_mk" > /etc/xinetd.d/check_mk
  echo "{" >> /etc/xinetd.d/check_mk
  echo "type		= UNLISTED" >> /etc/xinetd.d/check_mk
  echo "port		= 6556" >> /etc/xinetd.d/check_mk
  echo "socket_type	= stream" >> /etc/xinetd.d/check_mk
  echo "protocol	= tcp" >> /etc/xinetd.d/check_mk
  echo "wait		= no" >> /etc/xinetd.d/check_mk
  echo "user		= root" >> /etc/xinetd.d/check_mk
  echo "server		= /usr/bin/check_mk_agent" >> /etc/xinetd.d/check_mk
  echo "# configure the IP address(es) of your Nagios server here:" >> /etc/xinetd.d/check_mk
  echo "only_from       = 127.0.0.1 $SERVIDOR1 $SERVIDOR2" >> /etc/xinetd.d/check_mk
  echo "disable		= no" >> /etc/xinetd.d/check_mk
  echo "}" >> /etc/xinetd.d/check_mk


  #Reiniciamos el servicio Xinetd
  /etc/init.d/xinetd restart

 #Configuración de Firewalls
 # echo "#Configuración de Firewall#"
 # iptables -A INPUT -d $DPRIV -p tcp --dport 6556 -s $SERVIDOR1 --sport 1024:65535 -j ACCEPT
 # iptables -A INPUT -d $DPRIV -p tcp --dport 6556 -s $SERVIDOR2 --sport 1024:65535 -j ACCEPT
}


#Instalación del PlugIns mk_logwatch
function Lista-Plugins () {
  echo "Instalación de mk_logwatch"
  echo "Control de sistema"
  whatso

if [[ $SO == DEBIAN || UBUNTU ]]; then
  dpkg -l | grep check-mk-agent > /dev/null
  if [ $? -eq 0 ]; then
      if [ -d $PATHPLUGINS ] ;
        then

          echo "Descargando Lista de Plugins Generales"
          wget -P $PATHPLUGINS/ http://$SERVIDOR1/$SITIO/check_mk/agents/plugins/mk_apt
          wget -P $PATHPLUGINS/ http://$SERVIDOR1/$SITIO/check_mk/agents/plugins/mk_logins
          wget -P $PATHPLUGINS/ http://$SERVIDOR1/$SITIO/check_mk/agents/plugins/dnsclient
          #wget -P $PATHPLUGINS/ http://$SERVIDOR1/$SITIO/check_mk/agents/plugins/mk_iptables
          wget -P $PATHPLUGINS/ http://$SERVIDOR1/$SITIO/check_mk/agents/plugins/mk_logwatch.py
          wget -P $PATHPLUGINS/ http://$SERVIDOR1/$SITIO/check_mk/agents/plugins/netstat.linux
          #wget -P /etc/check_mk/ http://$SERVIDOR1/$SITIO/check_mk/agents/plugins/lvm

          echo "Otorgamos Permisos de ejecución a los plugins"
          chmod -R 755 $PATHPLUGINS/

          #Descargamos archivos de configuración
          wget -P /etc/check_mk/ http://$SERVIDOR1/$SITIO/check_mk/agents/cfg_examples/logwatch.cfg
      fi
  else
      clear
      echo "El agente check_mk no se encuentra instalado"
      echo "Debe ingresar la opción 1 para instalarlo"
      sleep 4
      menu
  fi
fi
#fin dela función
}


function mailman-Plugin () {
   #statements
   echo "Descargamos el plugin"
   wget -P $PATHPLUGINS/ http://$SERVIDOR1/$SITIO/check_mk/agents/plugins/mailman_lists

   echo "Otorgamos Permisos de ejecución a los plugins"
   chmod 755 -R $PATHPLUGINS

    }

 function apache-Plugin() {
   #statements
   echo "Descargamos el plugin"
   wget -P $PATHPLUGINS/ http://$SERVIDOR1/$SITIO/check_mk/agents/plugins/apache_status.py
   echo "Otorgamos Permisos de ejecución a los plugins"
   chmod -R 755 $PATHPLUGINS

      #Descargamos archivos de configuración
   wget -P /etc/check_mk/ http://$SERVIDOR1/$SITIO/check_mk/agents/cfg_examples/apache_status.cfg
   echo "Debemos configurar apache para utilizar mod-status"
 }

 function nginx-Plugin() {
   #statements
   echo "Descargamos el plugin"
   wget -P $PATHPLUGINS/ http://$SERVIDOR1/$SITIO/check_mk/agents/plugins/nginx_status.py
   echo "Otorgamos Permisos de ejecución a los plugins"
   chmod -R 755 $PATHPLUGINS

      #Descargamos archivos de configuración
   wget -P /etc/check_mk/ http://$SERVIDOR1/$SITIO/check_mk/agents/cfg_examples/nginx_status.cfg
   echo "Debemos configurar Nginx para utilizar mod-status"
 }

 function nfs-Plugin() {
   #statements
   echo "Descargamos el plugin"
   wget -P $PATHPLUGINS/ http://$SERVIDOR1/$SITIO/check_mk/agents/plugins/mk_nfsiostat
   wget -P $PATHPLUGINS/ http://$SERVIDOR1/$SITIO/check_mk/agents/plugins/nfsexports

   echo "Otorgamos Permisos de ejecución a los plugins"
   chmod -R 755 $PATHPLUGINS
}

function mysql-Plugin() {
  #statements
  echo "Descargamos el plugin"
  wget -P $PATHPLUGINS/ http://$SERVIDOR1/$SITIO/check_mk/agents/plugins/mk_mysql
  echo "Otorgamos Permisos de ejecución a los plugins"
  chmod -R 755 $PATHPLUGINS
}

#LLAMOS Funciones
#DIbuja menus
function menu (){
clear
echo "~~~~~~~~~~~~~~~~~~~~~~~"
echo " Check_mk Agent/Plugins"
echo "~~~~~~~~~~~~~~~~~~~~~~~"
echo "1. Instalar el paquete check_mk_agent"
echo "2. Instalar lista de Plugins (mk_logwatch, mk_apt, mk_logins, dnsclient, netstat.linux, lvm) "
echo "3. Instalar Plugins para Mailman"
echo "4. Instalar Plugins para Apache2"
echo "5. Instalar Plugins para Nginx"
echo "6. Instalar Plugins para NFS"
echo "7. Instalar Plugins para MySQL"
echo "X. Exit"

read opcion
case $opcion in
  1 ) ins-check_mk_agent
  ;;
  2 ) Lista-Plugins
  ;;
  3) mailman-Plugin
  ;;
  4) apache-Plugin
  ;;
  5) nginx-Plugin
  ;;
  6) nfs-Plugin
  ;;
  7) mysql-Plugin
  ;;
  X ) exit 5
  ;;
esac

}


#ejecutamos funcion menu, para brindar la interacción con el usuario
#ultimamodificación
menu
