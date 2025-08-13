#!/bin/sh
### FIREWALL DEL DATACENTER
#prueba

IF_LAN=eth5
IF_EXT=eth4
IF_TUN=tun+
PRIVATE=10.8.0.0/24
RED_LAN=192.168.2.0/24
LOOP=127.0.0.1
DIREXT=192.168.1.110
IP_WEB=192.168.2.3
IP_WinS=192.168.2.4
IP_DNS=192.168.2.4
IPTABLES=/sbin/iptables

#Limpiamos un flush de rules.
$IPTABLES -F
#borramos cadenas de usuarios.
$IPTABLES -X
#Ponemos en cero paquetes y contadores.
$IPTABLES -Z

#limpiamos las reglas de nat
$IPTABLES -t nat -F
#Borramos candenas de usuarios de nat
$IPTABLES -t nat -X

##REGLAS PARANOICAS!!!!!!!!!!!!!!!!!!!!!
# Fijamos las politicas por defecto. Denegamos todo.
$IPTABLES -t filter -P INPUT DROP
$IPTABLES -t filter -P OUTPUT DROP
$IPTABLES -t filter -P FORWARD DROP


			# Al firewall tenemos acceso desde la red local
			#### pUEDE SER JODIDO VER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		$IPTABLES -A INPUT -s $RED_LAN -i $IF_LAN -j ACCEPT
			

########################################
# Denegacion de todo lo que PROVENGA DE
# IP's reservadas para redes privadas 
# de clase  B, D y E diferentes de 
# la nuestra

## Clase B
$IPTABLES -A INPUT -s 172.26.0.0/16 -j DROP

## Clase D 
$IPTABLES -A INPUT -s 224.0.0.0/4 -j DROP

## Clase E 
$IPTABLES -A INPUT -s 240.0.0.0/5 -j DROP


########################################
# Denegacion de todo lo que SE DIRIJA A
# IP's reservadas para redes privadas 
# de clase A, B, D y E diferentes de 


## Clase B
$IPTABLES -A INPUT -d 172.26.0.0/16 -j DROP

## Clase D 
$IPTABLES -A INPUT -d 224.0.0.0/4 -j DROP

## Clase E 
$IPTABLES -A INPUT -d 240.0.0.0/5 -j DROP




#permitir conexion entre las vpns.
$IPTABLES -A INPUT  -p udp  --sport 1024:65535  --dport 1194 -m state --state NEW -j LOG --log-prefix "[FW - VPN]"
$IPTABLES -A INPUT  -p udp  --sport 1024:65535  --dport 1194   -j ACCEPT
$IPTABLES -A OUTPUT -p udp  --sport 1194  --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
### Probado ok!!!!


#### Nat a servidores desde el exterior (INTERNET)
##DNAT

#Evia peticiones web a una maquina interna
#Evia peticiones web a una maquina interna (?)
$IPTABLES -A INPUT  -i $IF_EXT -p tcp  --dport 80 --sport 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -o $IF_EXT -p tcp --dport 1024:65535 --sport 80 -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A FORWARD  -i $IF_EXT -p tcp --dport 80 --sport 1024:65535 -j ACCEPT
$IPTABLES -A FORWARD  -i $IF_EXT -p tcp --dport 1024:65535 --sport 80 -j ACCEPT
$IPTABLES  -t nat -A PREROUTING -i $IF_EXT -p tcp  --dport 80 --sport 1024:65535  -j DNAT --to $IP_WEB:80
$IPTABLES  -t nat -A POSTROUTING -s $RED_LAN -o $IF_EXT  -p  tcp --dport 1024:65535 --sport 80 -j SNAT --to $IP_WEB:80




# Permitimos paquetes ICMP (ping, traceroeut...) 
#+ con limites para evitar ataques de DoS
# Aceptamos ping y pong
### Probado ok!!!!
$IPTABLES -A INPUT   -p icmp --icmp-type echo-request  -m limit --limit 2/s -j ACCEPT
$IPTABLES -A OUTPUT  -p icmp --icmp-type echo-request  -m limit --limit 2/s -j ACCEPT
$IPTABLES -A INPUT   -p icmp --icmp-type echo-reply    -m limit --limit 2/s -j ACCEPT
$IPTABLES -A OUTPUT  -p icmp --icmp-type echo-reply    -m limit --limit 2/s -j ACCEPT

# Aceptamos redirecciones
$IPTABLES -A INPUT   -p icmp --icmp-type redirect      -m limit --limit 2/s -j ACCEPT
 $IPTABLES -A OUTPUT  -p icmp --icmp-type redirect      -m limit --limit 2/s -j ACCEPT

# Aceptamos tiempo excedido
$IPTABLES -A INPUT   -p icmp --icmp-type time-exceeded -m limit --limit 2/s -j ACCEPT
$IPTABLES -A OUTPUT  -p icmp --icmp-type time-exceeded -m limit --limit 2/s -j ACCEPT

# Aceptamos destino inalcanzable
$IPTABLES -A INPUT   -p icmp --icmp-type destination-unreachable -m limit --limit 2/s -j ACCEPT
$IPTABLES -A OUTPUT  -p icmp --icmp-type destination-unreachable -m limit --limit 2/s -j ACCEPT


		############# REGLAS PARA EL TUNEL VPN ###################
###########################################################################################################################
#Ya probado y funciona!!!! hay comunicacion entre los quipos atraves
#de las vpns
# Permitimos que del datacenter se pudan conectar a los servers por, ssh o telnet, pero no ala inversa.
##########################################################################################################################
##########################################################################################################################

	$IPTABLES -A INPUT -i   $IF_TUN -j ACCEPT
	#$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -j ACCEPT
	#$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -j ACCEPT
	$IPTABLES -A OUTPUT -o  $IF_TUN -j ACCEPT
	
		

	#FORWARD PARA EL TUNEL YA QUE SON IP FIJAS.
	### PERMITE INGRESO DE PUERTOS DE ADMINISTRACION ATRABES DEL TUNEL A QUIPOS INTERNOS.
	### Provado ok!!!!
	# LOG SSH
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -p tcp  --sport 1024:65535 --dport 22  -m state --state NEW -j LOG --log-prefix "[S Tun - SSH]"
	# CONEXION SSH
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -p tcp  --sport 1024:65535  --dport 22 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -p tcp  --sport 22 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	
	#Cortamos el acceso ssh desde el tunel asia el server vpn
	$IPTABLES -A INPUT -i $IF_TUN -p tcp --sport 1024:65535 --dport 22 -m state --state NEW -j LOG --log-prefix "[InTSSH-sotun]"	
	$IPTABLES -A INPUT -i $IF_TUN -p tcp --sport 1024:65535 --dport 22 -j DROP
		
	# LOG TELNET
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -p tcp --sport 1024:65535 --dport 23  -m state --state NEW -j LOG --log-prefix "[S Tun - TELNET]"
	# CONEXION TELNET
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -p tcp  --dport 23 --sport 1024:65535  -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -p tcp  --sport 23 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT	
	
	# WWW.NHGESTION.net.
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -p tcp --dport 80 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -p tcp --sport 80 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	###
	#ACIA SOCURSALES
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -p tcp --dport 80 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -p tcp --sport 80 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	


	#Puertos usados en la replicacion de Active Directory.
	#UDP/TCP 53 – DNS (Utilizado para esta tarea, y para resolver el camino al sitio interno del sistema gestion www.nhgestion.net)
	#UDP/TCP 88 – KERBEROS
	#TCP 135 – RPC (Remote Procedure call / Llamada al procedimiento remoto)
	#UDP/TCP 389 – (LDAP)
	#UDP/TCP 445 SMB sobre IP
	#TCP 636 – LDAP sobre SSL
	#TCP 3268 – Global Catalog (LDAP)	
	#udp/tcp 137 138 139 - netbios
	
	### Permite conexiones DNS
	### Asia las socursales
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN  -p tcp --dport 53 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN  -p tcp --sport 53 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN  -p udp --dport 53 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN  -p udp --sport 53 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	### Desde las Socursales
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --dport 53 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --sport 53 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p udp --dport 53 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p udp --sport 53 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	###

	## LDAP  win03
	### Permite conexiones LDAP
	### Asia las socursales
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -p tcp --dport 389 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -p tcp --sport 389 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -p udp --dport 389 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -p udp --sport 389 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	### Desde las Socursales
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --dport 389 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --sport 389 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p udp --dport 389 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p udp --sport 389 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	
	#No detectado por el snifer
	### Permite conexiones LDAP SSL (puede ser que este no funcine atraves de la 
	##vpn, por utilizar la misma encriptacion.!!!!!!)
	### Asia las socursales
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -p tcp --dport 636 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -p tcp --sport 636 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	### Desde las Socursales
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --dport 636 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --sport 636 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	
	

	### Permite conexiones GC (global catalogo)
	### Asia las socursales
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -p tcp --dport 3268 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -p tcp --sport 3268 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	### Desde las Socursales
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --dport 3268 --sport 1024:65535 -j ACCEPT 
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --sport 3268 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	
	###No detectado por el sniffer
	### Permite conexiones GC SEGURO (global catalogo)
	### Asia las socursales
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -p tcp --dport 3269 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -p tcp --sport 3269 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	### Desde las Socursales
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --dport 3269 --sport 1024:65535 -j ACCEPT 
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --sport 3269 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	
	### Permite conexiones Kerberos
	### Asia las socursales
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --dport 88 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --sport 88 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p udp --dport 88 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p udp --sport 88 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	### Desde las Socursales
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --dport 88 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --sport 88 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p udp --dport 88 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p udp --sport 88 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
     

	### Permite conexion SMB sobre ip
	### Asia las socursales 
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --dport 445 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --sport 445 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p udp --dport 445 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p udp --sport 445 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	### Desde las Socursales
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --dport 445 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --sport 445 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p udp --dport 445 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p udp --sport 445 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT

	### Permite conexiones RPC (Remote procedure call)
	### Asia las socursales
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --dport 135 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --sport 135 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	## Desde las Socursales
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --dport 135 --sport 1024:65535 -j ACCEPT 
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --sport 135 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	        
	### Netbios
	### Permite conexiones netbios
	### Asia las socursales
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --dport 137 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --sport 137 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p udp --dport 137 --sport 1024:65535 -j ACCEPT
 	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p udp --sport 137 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	### Desde las Socursales
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --dport 137 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --sport 137 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p udp --dport 137 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p udp --sport 137 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	###
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --dport 138 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --sport 138 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p udp --dport 138 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p udp --sport 138 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	### Desde las Socursales
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --dport 138 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --sport 138 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p udp --dport 138 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p udp --sport 138 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	###
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --dport 139 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --sport 139 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p udp --dport 139 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p udp --sport 139 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	### Desde las Socursales
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p tcp --dport 139 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p tcp --sport 139 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -d $IP_WinS -p udp --dport 139 --sport 1024:65535 -j ACCEPT
	$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -s $IP_WinS -p udp --sport 139 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
	###
	
### Servicios VoIP utilizando 
$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -p udp  --dport 4569 --sport 1024:65535 -m state --state NEW -j LOG --log-prefix "[STun-IAX2 DESDC]"
#CONEXION DESTINO DC IAX2
$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -p tcp  --dport 4569 --sport 1024:65535 -j ACCEPT
$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -p tcp  --sport 4569  --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT
#CONEXION DESTINO SOCURSAL IAX2
$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -p udp  --dport 4569 --sport 1024:65535 -m state --state NEW -j LOG --log-prefix "[STun-IAX2 DESSO]"
$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN -p tcp  --dport 4569 --sport 1024:65535 -j ACCEPT
$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN -p tcp  --sport 4569  --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT

	
#PERMITIENDO conexiones ICMP
$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN  -p icmp --icmp-type echo-request  -m limit --limit 2/s -j ACCEPT
$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN  -p icmp --icmp-type echo-request  -m limit --limit 2/s -j ACCEPT

$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN  -p icmp --icmp-type echo-reply    -m limit --limit 2/s -j ACCEPT
$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN  -p icmp --icmp-type echo-reply    -m limit --limit 2/s -j ACCEPT
	
# Aceptamos redirecciones
$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN   -p icmp --icmp-type redirect      -m limit --limit 2/s -j ACCEPT
$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN  -p icmp --icmp-type redirect      -m limit --limit 2/s -j ACCEPT

# Aceptamos tiempo excedido
$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN   -p icmp --icmp-type time-exceeded -m limit --limit 2/s -j ACCEPT
$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN  -p icmp --icmp-type time-exceeded -m limit --limit 2/s -j ACCEPT

# Aceptamos destino inalcanzable
$IPTABLES -A FORWARD -i $IF_TUN -o $IF_LAN   -p icmp --icmp-type destination-unreachable -m limit --limit 2/s -j ACCEPT
$IPTABLES -A FORWARD -i $IF_LAN -o $IF_TUN  -p icmp --icmp-type destination-unreachable -m limit --limit 2/s -j ACCEPT


##########################################################################################################################
#######################################################################################################################

	
	#Permitir loopback local
	### Probado ok!!!!
$IPTABLES -A INPUT -s $LOOP -d $LOOP  -j ACCEPT
$IPTABLES -A OUTPUT -d $LOOP -s $LOOP -j ACCEPT



##########################################################################
### Conexiones cliente, Utilizando este equipo como cliente.
### la razon de esto es para poder actualizar, instalar paquetes y realizar estas conexiones desde este ###equipo, sino imposible.
### Probado ok!!!!
#Permitiendo DNS Lookups como un cliente

$IPTABLES -A INPUT  -p udp --sport 53 --dport 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p udp --dport 53 --sport 1024:65535 -j ACCEPT

$IPTABLES -A INPUT  -p tcp --sport 53 --dport 1024:65525 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 53 --sport 1024:65525 -j ACCEPT

	# Acceso http estándar

$IPTABLES -A INPUT  -p tcp  --sport 80 --dport 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp  --dport 80 --sport 1024:65535 -j ACCEPT
  
	# Acceso https estándar

$IPTABLES -A INPUT  -p tcp  --sport 443 --dport 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp  --dport 443 --sport 1024:65535 -j ACCEPT
 
	#Acceso ftp estándar

$IPTABLES -A INPUT  -p tcp  --sport 21 --dport 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp  --dport 21 --sport 1024:65535 -j ACCEPT

	#Respuestas del canal de datos FTP modo puerto normal

$IPTABLES -A INPUT  -p tcp  --sport 20 --dport 1024:65535 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp  --dport 20 --sport 1024:65535 -j ACCEPT


##########################################################################
## AHORA CON REGLA FORWARD FILTRAMOS EL ACCESO DE LA RED LOCAL
## AL EXTERIOR. A LOS PAQUETES QUE NO VAN DIRIGIDOS AL
## PROPIO FIREWALL SE LES APLICAN REGLAS DE FORWARD
## OJO!!!! Funciona por que despues se hace enmascaramiento.    
### Probado ok!!!!

# Acceso ftp estandar
$IPTABLES -A FORWARD -s $RED_LAN -i $IF_LAN  -p tcp --dport 21 -j ACCEPT
$IPTABLES -A FORWARD -i $IF_EXT -o $IF_LAN -p tcp --sport 21 -m state --state RELATED,ESTABLISHED -j ACCEPT


$IPTABLES -A FORWARD -s $RED_LAN -i $IF_LAN  -p tcp --dport 20 -j ACCEPT
$IPTABLES -A FORWARD -i $IF_EXT -o $IF_LAN -p tcp --sport 20 -m state --state RELATED,ESTABLISHED -j ACCEPT


# Aceptamos que vayan a puertos 80
$IPTABLES -A FORWARD -s $RED_LAN  -i $IF_LAN -p tcp --dport 80 -j ACCEPT
$IPTABLES -A FORWARD -i $IF_EXT -o $IF_LAN -p tcp --sport 80 -m state --state RELATED,ESTABLISHED -j ACCEPT


# Aceptamos que vayan a puertos https
$IPTABLES -A FORWARD -s $RED_LAN  -i $IF_LAN -p tcp --dport 443 -j ACCEPT
$IPTABLES -A FORWARD -i $IF_EXT -o $IF_LAN -p tcp --sport 443 -m state --state RELATED,ESTABLISHED -j ACCEPT


# Aceptamos que consulten los DNS
$IPTABLES -A FORWARD -s $RED_LAN -i $IF_LAN  -p tcp --dport 53 -j ACCEPT
$IPTABLES -A FORWARD -i $IF_EXT -o $IF_LAN -p tcp --sport 53 -m state --state RELATED,ESTABLISHED -j ACCEPT 

$IPTABLES -A FORWARD -s $RED_LAN -i $IF_LAN  -p udp --dport 53 -j ACCEPT
$IPTABLES -A FORWARD -i $IF_EXT -o $IF_LAN -p udp --sport 53 -m state --state RELATED,ESTABLISHED -j ACCEPT 

#ping
$IPTABLES -A FORWARD -s $RED_LAN -i $IF_LAN   -p icmp --icmp-type echo-request  -m limit --limit 2/s -j ACCEPT
$IPTABLES -A FORWARD -i $IF_EXT -o $IF_LAN   -p icmp --icmp-type echo-request  -m limit --limit 2/s -m state --state RELATED,ESTABLISHED -j ACCEPT

#pong
$IPTABLES -A FORWARD -s $RED_LAN -i $IF_LAN   -p icmp --icmp-type echo-reply    -m limit --limit 2/s -j ACCEPT
$IPTABLES -A FORWARD -i $IF_EXT -o $IF_LAN   -p icmp --icmp-type echo-reply -m limit --limit 2/s  -m state --state RELATED,ESTABLISHED -j ACCEPT
 
# Aceptamos redirecciones
$IPTABLES -A FORWARD -s $RED_LAN -i $IF_LAN  -p icmp --icmp-type redirect    -m limit --limit 2/s   -j ACCEPT
$IPTABLES -A FORWARD -i $IF_EXT -o $IF_LAN   -p icmp --icmp-type redirect -m limit --limit 2/s  -m state --state RELATED,ESTABLISHED -j ACCEPT

# Aceptamos tiempo excedido
$IPTABLES -A FORWARD -s $RED_LAN -i $IF_LAN  -p icmp --icmp-type time-exceeded -m limit --limit 2/s  -j ACCEPT
$IPTABLES -A FORWARD -i $IF_EXT -o $IF_LAN   -p icmp --icmp-type time-exceeded -m limit --limit 2/s  -m state --state RELATED,ESTABLISHED -j ACCEPT

# Aceptamos destino inalcanzable
$IPTABLES -A FORWARD -s $RED_LAN -i $IF_LAN  -p icmp --icmp-type destination-unreachable -m limit --limit 2/s -j ACCEPT
$IPTABLES -A FORWARD -i $IF_EXT -o $IF_LAN   -p icmp --icmp-type destination-unreachable -m limit --limit 2/s  -m state --state RELATED,ESTABLISHED -j ACCEPT

# Ahora hacemos enmascaramiento de la red local (ESTO ES LA PEQUEÑA MAGIA DEL NAT)
# Esto lo que realisa es otorgar una ip ficticia dinamicamente, cuando un equipo se conecta  asia fuera.
$IPTABLES -t nat -A POSTROUTING -s $RED_LAN -o $IF_EXT -j MASQUERADE
