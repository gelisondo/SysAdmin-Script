#!/bin/bash
cowsay "Hi, How are you"
echo "###########################################################################"
echo "#####     Este es un pequeño escripts para trabajar con test y if.    #####"
echo "###########################################################################"
sleep 1
echo ""
clear

echo "Ingresa el numero del menu a las preguntas o acciones correspodientes"

function contronl()
{
	
	 if test -n $menu;
	 then
		if [ $menu -eq 1 ] || [ $menu -eq 2 ] || [ $menu -eq 3 ];
			then 
				echo "su valor es $menu"
				sleep 1
				CONT=1
			else
		
				echo "el valor esta vacio"
		fi
	 fi		
}

CONT=0

while [ $CONT -eq 0 ];
do

		clear
        echo "1: Trabajamos con archivos"
        echo "2: Comparaciones aritmeticas, e implementación de comandos" 
        echo "3: TRabajamos con strings"
        read menu
        contronl
                
done

case $menu in
 1)
	clear
	echo "Verificamos la existencia de archivos:"
	echo "archivos en este directorio"
	ls
	echo "Ingresa la ruta del archivo"
	read ruta
	
	if test  -z $ruta;
	then 
		echo "la variable esta vacia"
		sleep 2
		exit 0
	fi 

	# Verificamso que sea un archivo legible
	if test -f $ruta;
	then
		echo "El archivo $ruta es un archivo legible"

	   r=0
	   w=0
	   x=0

	   if test -r $ruta;
	   then
		echo "Es un archivo readable/leible"
		r=4
	   fi
	   if test -w $ruta;
	   then
		echo "Es un archivo writeable/Escribible"
		w=2
	   fi	
	   if test -x $ruta;
	   then
		echo "Es un archivo executable/ejecutable"
		x=1
	   fi
	   if test -r $ruta;
	   then
		echo "Es un archivo readable/leible"
	   fi

	   yo=`whoami`
	   echo "permisos efectivos para el usuario $yo en el archivo $ruta"
	   echo " $r $w $x "
	   echo `expr $r + $w + $x`
	   echo "permisos efectivos"
	   ls -l $ruta
	fi
 ;;
2)
	echo "a: Prueba de dirección ip"
	read dos

	case $dos in
	   a)
		echo "ingrese la ip del host a verificar"
		read ip
		ping -c 1 $ip > /dev/null
		if test $? -eq 0
		then
			echo "El host $ip esta activo"
		else
			echo "El host $ip no esta activo o existio un problema en la red"
		fi

		;;
	   *)
		echo "ingreso mal el menu"
		exit 0
		;;
 	   esac
    ;;
 *)
	echo "Debe ingresar las opciones 1 , 2 o 3"
	exit 0
esac

	


