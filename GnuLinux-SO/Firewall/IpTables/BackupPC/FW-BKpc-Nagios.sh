#/bin/bash

###########################################################################

### Bloque 1. Variables


DPRIV=164.73.188.16
DPUBL=164.73.188.16

REDLOCALSER=164.73.188.0/27

TECNOTEBOOK1=164.73.188.17
TECNOTEBOOK2=164.73.188.7
TECPC=164.73.188.16



REDSECIU=164.73.129.0/24

MASCARAAD=255.255.255.192
MASCARASER=255.255.255.224

IPT=/sbin/iptables


root@Picoro-BK:~# cat /etc/init.d/FW-BKpc.sh 
#/bin/bash

###########################################################################

### Bloque 1. Variables


DPRIV=164.73.188.16
DPUBL=164.73.188.16

REDLOCALSER=164.73.188.0/27

TECNOTEBOOK1=164.73.188.17
TECNOTEBOOK2=164.73.188.7
TECPC=164.73.188.16



REDSECIU=164.73.129.0/24

MASCARAAD=255.255.255.192
MASCARASER=255.255.255.224

IPT=/sbin/iptables


if [ ! -x $IPT ]; then
  exit 0
fi



#########################################################################
### Bloque 2. Inicialización básica
# Limpia la lista de reglas

$IPT -F

# Tráfico sin restricciones sobre la interfaz loopback (lo)

$IPT -A INPUT -i lo -j ACCEPT

##########################################################################
### Bloque 3. Ataques específicos


##########
# Spoofing
# Rechaza paquetes que afirmen ser o venir de una red privada Clase A
$IPT -A INPUT -i eth0 -s 10.0.0.0/8 -j DROP

$IPT -A INPUT -i eth0 -d 10.0.0.0/8 -j DROP

# Rechaza paquetes que afirmen ser o venir de una red privada Clase B
$IPT -A INPUT -i eth0 -s 172.16.0.0/12 -j DROP

$IPT -A INPUT -i eth0 -d 172.16.0.0/12 -j DROP

# Rechaza paquetes que afirmen ser o venir de una red multicast Clase D
$IPT -A INPUT -i eth0 -s 224.0.0.0/4 -j DROP

# Rechaza paquetes que afirmen ser o venir de una red reservada Clase E

$IPT -A INPUT -i eth0 -s 240.0.0.0/5 -j DROP



# Rechaza paquetes que afirmen ser o venir de loopback
$IPT -A INPUT -i eth0 -s localhost -j DROP

# Rechaza paqetes broadcast mal formados
$IPT -A INPUT -i eth0 -s 255.255.255.255 -j DROP

$IPT -A INPUT -i eth0 -d 0.0.0.0 -j DROP

######
# icmp
# Permitimos paquetes ICMP (ping, traceroute...) 
#+ con limites para evitar ataques de DoS
# Aceptamos ping y pong

$IPT -A INPUT   -p icmp --icmp-type echo-request  -m limit --limit 2/s -j ACCEPT
$IPT -A OUTPUT  -p icmp --icmp-type echo-request  -m limit --limit 2/s -j ACCEPT
$IPT -A INPUT   -p icmp --icmp-type echo-reply    -m limit --limit 2/s -j ACCEPT
$IPT -A OUTPUT  -p icmp --icmp-type echo-reply    -m limit --limit 2/s -j ACCEPT

# Aceptamos redirecciones
$IPT -A INPUT   -p icmp --icmp-type redirect      -m limit --limit 2/s -j ACCEPT
$IPT -A OUTPUT  -p icmp --icmp-type redirect      -m limit --limit 2/s -j ACCEPT



# Aceptamos tiempo excedido

$IPT -A INPUT   -p icmp --icmp-type time-exceeded -m limit --limit 2/s -j ACCEPT
$IPT -A OUTPUT  -p icmp --icmp-type time-exceeded -m limit --limit 2/s -j ACCEPT

# Aceptamos destino inalcanzable

$IPT -A INPUT   -p icmp --icmp-type destination-unreachable -m limit --limit 2/s -j ACCEPT
$IPT -A OUTPUT  -p icmp --icmp-type destination-unreachable -m limit --limit 2/s -j ACCEPT

#######
# smurf
# Ataque de tipo DoS (denegación de servicios)


#$IPT -A INPUT -d 255.255.255.255 -p icmp -j DROP
# Ataque DoS de direcciones de red
# $IPT -A INPUT -d $MASCARA -p icmp -j DROP
##########################################################################

### Bloque 4. Servicios disponibles
# Solicitud entrante de ssh desde SeCIU
#TECNOTEBOOK2=

$IPT -A INPUT -d $DPRIV -p tcp --dport 22 -s $TECNOTEBOOK1 --sport 1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -p tcp --dport 22 -s $TECNOTEBOOK2 --sport 1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -p tcp --dport 22 -s $TECPC --sport 1024:65535 -j ACCEPT

# Solicitud entrante de ssh desde red local solo ip de gestion tecnica
#$IPT -A INPUT -d $DPRIV -p tcp --dport 22 -s $REDLOCALSER --sport 1024:65535 -j ACCEPT

# Solicitudes http de entrada
$IPT -A INPUT -d $DPRIV -p tcp --dport 80 -s $TECNOTEBOOK1 --sport 1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -p tcp --dport 80 -s $TECNOTEBOOK2 --sport 1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -p tcp --dport 80 -s $TECPC --sport 1024:65535 -j ACCEPT


# Solicitudes https (ssl) de entrada
$IPT -A INPUT -d $DPRIV -p tcp --dport 443 -s $TECNOTEBOOK1 --sport 1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -p tcp --dport 443 -s $TECNOTEBOOK2 --sport 1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -p tcp --dport 80 -s $TECPC --sport 1024:65535 -j ACCEPT


# Permitimos Coinexion para el puero RSYNC
$IPT -A OUTPUT -d $REDLOCALSER -p tcp --dport 873 -s $DPRIV  --sport 1024:65535  -j ACCEPT
$IPT -A INPUT -d $DPRIV -p tcp --dport 1024:65535 -s $REDLOCALSER  --sport 873   -j ACCEPT


##########################################################################
### Bloque 5. Conexiones cliente

#Permitiendo DNS Lookups como un cliente

$IPT -A INPUT  -p udp --sport 53 --dport 1024:65535 -j ACCEPT
$IPT -A OUTPUT -p udp --dport 53 --sport 1024:65535 -j ACCEPT
$IPT -A INPUT  -p tcp --sport 53 --dport 1024:65525 -j ACCEPT
$IPT -A OUTPUT -p tcp --dport 53 --sport 1024:65525 -j ACCEPT

	# Acceso http estándar

$IPT -A INPUT  -p tcp  --sport 80 --dport 1024:65535 -j ACCEPT
$IPT -A OUTPUT -p tcp  --dport 80 --sport 1024:65535 -j ACCEPT

	# Acceso https estándar

$IPT -A INPUT  -p tcp  --sport 443 --dport 1024:65535 -j ACCEPT
$IPT -A OUTPUT -p tcp  --dport 443 --sport 1024:65535 -j ACCEPT

	#Acceso ftp estándar

$IPT -A INPUT  -p tcp  --sport 21 --dport 1024:65535 -j ACCEPT
$IPT -A OUTPUT -p tcp  --dport 21 --sport 1024:65535 -j ACCEPT

	#Respuestas del canal de datos FTP modo puerto normal
$IPT -A INPUT  -p tcp  --sport 20 --dport 1024:65535 -j ACCEPT
$IPT -A OUTPUT -p tcp  --dport 20 --sport 1024:65535 -j ACCEPT


	#accesso a SSH
$IPT -A INPUT  -p tcp  --sport 22 --dport 1024:65535 -j ACCEPT
$IPT -A OUTPUT -p tcp  --dport 22 --sport 1024:65535 -j ACCEPT

	#apt-cacher
$IPT -A INPUT   -p tcp  -s 164.73.188.22 --sport  3142 --dport 1024:65535 -j ACCEPT
$IPT -A OUTPUT  -p tcp  -d 164.73.188.22 --dport 3142 --sport 1024:65535 -j ACCEPT

	#Acceso a Imap (Thunderbir)
$IPT -A INPUT -p tcp  --sport 143 --dport 1024:65535 -j ACCEPT
$IPT -A OUTPUT -p tcp --dport 143 --sport 1024:65535  -j ACCEPT

	#Acceso a SMTP (Thunderbir)
$IPT -A INPUT  -p tcp --sport 25 --dport 1024:65535 -j ACCEPT
$IPT -A OUTPUT -p tcp --dport 25 --sport 1024:65535 -j ACCEPT


##########################################################################

### Bloque 6. Reglas por defecto
# Bloquea cualquier otro tipo de conexiÃ³n que se intente hacer fuera de las que estÃ¡n aquÃ­
$IPT -P INPUT DROP
$IPT -P OUTPUT ACCEPT
 
