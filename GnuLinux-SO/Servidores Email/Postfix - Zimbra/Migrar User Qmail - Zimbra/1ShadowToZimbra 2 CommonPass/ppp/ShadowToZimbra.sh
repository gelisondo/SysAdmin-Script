#!/bin/bash
# Shadow to Zimbra import
## Created by Jarosław Czarniak on 26-10-2008
# Modificado por: Guillermo Elisondo
# Departamento :Servicio Tecnico SysAdmin
# Proposito: Comparamos los usuarios validos con los existentes en shadow, de este le sacamos la contraseña para generar un nuevo scrip para exportar los usuarios a zimbra.

clear
echo "Uso del script generado en el servidor destino."
echo "Este se tiene que ejecutar con el usuario zimbra"
echo ">./sh2ladp.sh"

domain="enba.edu.uy"  # change to your domain!
file="sh2ldap.sh"
shadow="/etc/shadow" #lugar donde se encuentra el pa
x=0
echo "#!/bin/bash" > $file

#1) Recorremos el Archivo  UQmail.txt
#2) Por cada linea del archivo UQmail.txt comparamos si considen las entradas con los usuarios del shadow
#Descomentar si es la primera ves el siguiente comando
ls /home/ > UQmail.txt

#Recorremos el archivo UQmail.txt
for lqmail in `cat UQmail.txt`
do
    
    #verifica si es un directorios que contenga una estructura MAILDIR
    #Si es a si, es un usuario valido.
    if test -d /home/$lqmail/Maildir/
    then
	#Recorremos el archivo shadow para comparar si considen los usuarios	
	for line in `cat $shadow`
	do
		#Extraemos el  usuarios del archivo shadow
		user=`echo $line | cut -f1 -d":"`


	#Verificamos que los usuairos sean los mismos.
	if [ "$lqmail" == "$user" ]
	then
		echo "los usuarios son iguales $user"
		#Extraemos la contraseña encriptada
 		pass=`echo $line | cut -f2 -d":"`

	    if [ "$pass" != "*" ]
	    then
	        if [ "$pass" != "!" ]
	        then

	            echo "zmprov ca $user@$domain temppasswordQAZXSW displayName $user">>$file
	            echo "zmprov ma $user@$domain userPassword '{crypt}$pass'">>$file
		    #Generamos el segundo archivo de usuarios ya verificado.
		    echo $user >> UQmail2.txt
	            x=$[x+1]
	        fi
	    fi
	fi
	done
     fi
done
echo
echo
echo " $x Cuentas exportadas en el archivo  \"$PWD/$file\""

sleep 5
