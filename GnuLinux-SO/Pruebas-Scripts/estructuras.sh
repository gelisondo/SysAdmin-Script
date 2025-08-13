#!/bin/bash
## Este shell script mostrara varias opcionnes, dependiendo de cul elijamos sera lo que hara.
## para realizar el menu uzaremos "case" y para realizar las diferentes tareas usaremos "funciones"..
clear 
echo "## Bienbenidos a Loly el Script multitarea ##"
echo "## Este les falicitara tareas importante ..##"
echo "        ##@@@ FOR THE LIFE @@@##"
echo ""
echo ""
echo " Igrese una de las siguientes opciones"
echo "1. Verifica valor"
echo "2. Muestra contenido y tamaño"
echo "3. Descarga instrucciones de sexo"
read tarea

##Primer control
##Verificar si esxiste un contenido!!
#Quita los caracteres que no sean digitos
nodigitos="$(echo $tarea | sed s/[0-9]//g)" 
if [ -n "$nodigitos" ];
then
	echo "No hay dijitos validos"
	exit 0 
fi  

function ver {
  if test $Num -eq 5
  then 
  			echo "es igual"
  			return 1
  	else
  			echo "no es igual"
  			return 0
  	fi				 
}

case $tarea in
1)
 	echo "Ingrese el valor"
 	read  Num
 	ver
	
 	;;
2)
	echo "Tarea b"
	;;
3)
	echo "Tarea c"
	;;
esac
