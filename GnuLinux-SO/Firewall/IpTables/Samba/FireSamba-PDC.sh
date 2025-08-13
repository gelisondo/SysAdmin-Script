#!/bin/bash

##-Acceso-##
#Este scrip es un firewall basado en iptables para filtrar los siguientes servicios.
#ldap conexiones locales (samba,apache) > local
#ssh ips SysAdmin, Seciu
#samba ips SysAdmin, Red Administración
#apache Ips SysAdmin


#########################################################################
### Bloque 1. Variables
DPRIV=164.73.188.29
DPUBL=164.73.188.29

DPRIVoffice=164.73.188.125
DPUBLoffice=164.73.188.125

REDLOCALES=164.73.188.128/25
REDLOCALAD=164.73.188.64/26
REDLOCALSE=164.73.188.0/27

IPADMINISTRATOR1=164.73.188.7
IPADMINISTRATOR2=164.73.188.17
IPADMINISTRATOR3=164.73.188.6

REDSECIU=164.73.129.0/24
MASCARA=255.255.255.0

IPT=/sbin/iptables
#########################################################################
### Bloque 2. Inicialización básica

# Limpia la lista de reglas
$IPT -F

# Tráfico sin restricciones sobre la interfaz loopback (lo)
#Por ende funciona el LDAP.
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
#icmp
#Acepta todos los paquetes icmp
$IPT -A INPUT -p icmp -j ACCEPT

#######
# smurf
# Ataque de tipo DoS (denegación de servicios)
$IPT -A INPUT -d 255.255.255.255 -p icmp -j DROP

# Ataque DoS de direcciones de red
$IPT -A INPUT -d $MASCARA -p icmp -j DROP



####Contramedidas contra DDoS sobre http/https
#Crea nueva cadena
$IPT --new-chain BLACKLISTADD
$IPT --append BLACKLISTADD --match recent --name BLACKLIST --set --jump DROP
$IPT --append INPUT --match recent --name BLACKLIST --rcheck --seconds 900  --jump DROP
$IPT --append INPUT --match recent --name BLACKLIST --remove

#Seteando las conexiones 80 con el nombre http
$IPT --append INPUT --protocol tcp --dport 80 --in-interface eth0 --match state --state NEW --match recent --name http --set
#Bolcado de ips conflictivas a la cadena "BLACKLISTADO", que cumplan las siguientes reglas..
$IPT --append INPUT --protocol tcp --dport 80 --in-interface eth0 --match state --state NEW --match recent --update --seconds 2 --hitcount 20 --name http --jump BLACKLISTADD

#Seteando las conexiones 445 con el nombre https
$IPT --append INPUT --protocol tcp --dport 445 --in-interface eth0 --match state --state NEW --match recent --name https --set
#Bolcado de ips conflictivas a la cadena "BLACKLISTADO", que cumplan las siguientes reglas..
$IPT --append INPUT --protocol tcp --dport 445 --in-interface eth0 --match state --state NEW --match recent --update --seconds 2 --hitcount 20 --name http --jump BLACKLISTADD








##########################################################################

### Bloque 4. Servicios disponibles
##########################################################################
# Recibiendo correo como un servidor SMTP
$IPT -A INPUT -d $DPRIV -p tcp --dport 25 --sport 1024:65535 -j ACCEPT


#Solicitud entrante de ssh desde IPADMINISTRATOR local.
$IPT -A INPUT -d $DPRIV -p tcp --dport 22 -s $IPADMINISTRATOR1 --sport 1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -p tcp --dport 22 -s $IPADMINISTRATOR2 --sport 1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -p tcp --dport 22 -s $IPADMINISTRATOR3 --sport 1024:65535 -j ACCEPT

# Solicitud entrante de ssh desde SeCIU
$IPT -A INPUT -d $DPRIV -p tcp --dport 22 -s $REDSECIU --sport 1024:65535 -j ACCEPT
# Solicitud entrante de ssh desde red local
#$IPT -A INPUT -d $DPRIV -p tcp --dport 22 -s $REDLOCAL --sport 1024:65535 -j ACCEPT


# Solicitudes http de entrada
$IPT -A INPUT -d $DPRIV -p tcp --dport 80 -s $IPADMINISTRATOR1 --sport 1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -p tcp --dport 80 -s $IPADMINISTRATOR2 --sport 1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -p tcp --dport 80 -s $IPADMINISTRATOR3 --sport 1024:65535 -j ACCEPT

# Solicitudes shttp (ssl) de entrada
$IPT -A INPUT -d $DPRIV -p tcp --dport 443 -s $IPADMINISTRATOR1 --sport 1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -p tcp --dport 443 -s $IPADMINISTRATOR2 --sport 1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -p tcp --dport 443 -s $IPADMINISTRATOR3 --sport 1024:65535 -j ACCEPT



# Acceso Netbios samba, desde las maquinas de los SysAdmin
#Administrador 1
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p tcp --sport 1024:65535 --dport 137 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p tcp --sport 1024:65535 --dport 138 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p tcp --sport 1024:65535 --dport 139 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p tcp --sport 1024:65535 --dport 445 -j ACCEPT

$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p udp --sport 1024:65535 --dport 137 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p udp --sport 1024:65535 --dport 138 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p udp --sport 1024:65535 --dport 139 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p udp --sport 1024:65535 --dport 445 -j ACCEPT


#Administrador 2
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p tcp --sport 1024:65535 --dport 137 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p tcp --sport 1024:65535 --dport 138 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p tcp --sport 1024:65535 --dport 139 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p tcp --sport 1024:65535 --dport 445 -j ACCEPT

$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p udp --sport 1024:65535 --dport 137 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p udp --sport 1024:65535 --dport 138 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p udp --sport 1024:65535 --dport 139 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p udp --sport 1024:65535 --dport 445 -j ACCEPT



#Administrador 3
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p tcp --sport 1024:65535 --dport 137 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p tcp --sport 1024:65535 --dport 138 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p tcp --sport 1024:65535 --dport 139 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p tcp --sport 1024:65535 --dport 445 -j ACCEPT

$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p udp --sport 1024:65535 --dport 137 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p udp --sport 1024:65535 --dport 138 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p udp --sport 1024:65535 --dport 139 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p udp --sport 1024:65535 --dport 445 -j ACCEPT


## Acceso Netbios samba, desde la red de oficinas.
$IPT -A INPUT -s 164.73.188.64/26 -p tcp --sport 1024:65535 --dport 137 -j ACCEPT
$IPT -A INPUT -s 164.73.188.64/26 -p tcp --sport 1024:65535 --dport 138 -j ACCEPT
$IPT -A INPUT -s 164.73.188.64/26 -p tcp --sport 1024:65535 --dport 139 -j ACCEPT
$IPT -A INPUT -s 164.73.188.64/26 -p tcp --sport 1024:65535 --dport 445 -j ACCEPT

$IPT -A INPUT -s 164.73.188.64/26 -p udp --sport 1024:65535 --dport 137 -j ACCEPT
$IPT -A INPUT -s 164.73.188.64/26 -p udp --sport 1024:65535 --dport 138 -j ACCEPT
$IPT -A INPUT -s 164.73.188.64/26 -p udp --sport 1024:65535 --dport 139 -j ACCEPT
$IPT -A INPUT -s 164.73.188.64/26 -p udp --sport 1024:65535 --dport 445 -j ACCEPT



##########################################################################
# Samba como cliente

#Red  Administracion Officinas
$IPT -A INPUT  -s 164.73.188.64/26 -p tcp --sport 137  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT  -s 164.73.188.64/26 -p tcp --sport 138  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT  -s 164.73.188.64/26 -p tcp --sport 139  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT  -s 164.73.188.64/26 -p tcp --sport 445  --dport  1024:65535 -j ACCEPT

$IPT -A INPUT  -s 164.73.188.64/26 -p udp --sport 137  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT  -s 164.73.188.64/26 -p udp --sport 138  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT  -s 164.73.188.64/26 -p udp --sport 139  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT  -s 164.73.188.64/26 -p udp --sport 445  --dport  1024:65535 -j ACCEPT



#IPADMINISTRATOR3
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p tcp --sport 137  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p tcp --sport 138  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p tcp --sport 139  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p tcp --sport 445  --dport  1024:65535 -j ACCEPT

$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p udp --sport 137  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p udp --sport 138  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p udp --sport 139  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p udp --sport 445  --dport  1024:65535 -j ACCEPT

#IPADMINISTRATOR2
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p tcp --sport 137  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p tcp --sport 138  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p tcp --sport 139  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p tcp --sport 445  --dport  1024:65535 -j ACCEPT

$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p udp --sport 137  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p udp --sport 138  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p udp --sport 139  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p udp --sport 445  --dport  1024:65535 -j ACCEPT

#IPADMINISTRATOR1
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p tcp --sport 137  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p tcp --sport 138  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p tcp --sport 139  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p tcp --sport 445  --dport  1024:65535 -j ACCEPT

$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p udp --sport 137  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p udp --sport 138  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p udp --sport 139  --dport  1024:65535 -j ACCEPT
$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p udp --sport 445  --dport  1024:65535 -j ACCEPT



### Bloque 5. Conexiones cliente
# Permitiendo DNS Lookups como un cliente
$IPT -A INPUT  -p udp --sport 53 --dport 1024:65535 -j ACCEPT
$IPT -A INPUT  -p tcp --sport 53 --dport 1024:65525 -j ACCEPT

# Enviando correo a cualquier servidor de correo externo
$IPT -A INPUT -d $DPRIV -p tcp ! --syn --sport 25 --dport 1024:65535 -j ACCEPT

# Recuperando correo POP como cliente
$IPT -A INPUT -d $DPRIV -p tcp ! --syn --sport 110 --dport 1024:65535 -j ACCEPT

# Recuperando correo IMAP como cliente
$IPT -A INPUT -d $DPRIV -p tcp ! --syn --sport 143 --dport 1024:65535 -j ACCEPT

# Acceso http estándar
$IPT -A INPUT -d $DPRIV -p tcp ! --syn --sport 80 --dport 1024:65535 -j ACCEPT

# Acceso shttp estándar
$IPT -A INPUT -d $DPRIV -p tcp ! --syn --sport 443 --dport 1024:65535 -j ACCEPT

# Acceso ftp estándar
$IPT -A INPUT -d $DPRIV -p tcp ! --syn --sport 21 --dport 1024:65535 -j ACCEPT

# Canal de datos FTP modo pasivo
$IPT -A INPUT -d $DPRIV -p tcp ! --syn --sport 1024:65535 --dport 1024:65535 -j ACCEPT

# Respuestas del canal de datos FTP modo puerto normal
$IPT -A INPUT -d $DPRIV -p tcp --sport 20 --dport 1024:65535 -j ACCEPT

# Acceso Netbios estándar
#$IPT -A INPUT -d $DPRIV -s $DPRIoffice -p tcp ! --syn --sport netbios-ns:netbios-ssn:netbios-dgm --dport 1024:65535 -j ACCEPT
#$IPT -A INPUT -d $DPRIV -s $DPRIoffice -p udp --sport netbios-ns:netbios-ssn:netbios-dgm --dport 1024:65535 -j ACCEPT

#$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p tcp ! --syn --sport netbios-ns:netbios-ssn:netbios-dgm --dport 1024:65535 -j ACCEPT
#$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p tcp ! --syn --sport netbios-ns:netbios-ssn:netbios-dgm --dport 1024:65535 -j ACCEPT
#$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p tcp ! --syn --sport netbios-ns:netbios-ssn:netbios-dgm --dport 1024:65535 -j ACCEPT

#$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR1 -p udp ! --syn --sport netbios-ns:netbios-ssn:netbios-dgm --dport 1024:65535 -j ACCEPT
#$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR2 -p udp ! --syn --sport netbios-ns:netbios-ssn:netbios-dgm --dport 1024:65535 -j ACCEPT
#$IPT -A INPUT -d $DPRIV -s $IPADMINISTRATOR3 -p udp ! --syn --sport netbios-ns:netbios-ssn:netbios-dgm --dport 1024:65535 -j ACCEPT



##########################################################################

### Bloque 6. Reglas por defecto

# Bloquea cualquier otro tipo de conexión que se intente hacer fuera de las que están aquí

$IPT -P INPUT DROP

