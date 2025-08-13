#!/bin/bash
#Version: 1.0
#Mision: extraer Nombre de contacto y email de archivos .cvf
#Autor: Gelisondo.

clear
echo "Ingrese 1 si desea solo extraer el mail"
echo "Ingrese 2 si desea extraer el Nombre y el mail"
read accion
#accion=2

sleep 1
clear
pwd
ls
echo "ingrese el nombre del archivo"
read namefile
#namefile="cuarto.vcf"


if ! test -f $namefile ;
then
  echo "Eroor 01: el archivo no existe"
  exit 1
fi

#accion a tomar
if [ $accion = 2  ];
then
 echo "Se procedera a extraer en Nombre del usuario y El mail, de los contactos en el archivo $namefile"

CONTADORN=0
CONTADORM=0
 #cargamos el archivo
 for contact in `cat $namefile`
 do
#  echo $contact

#Verificamos y extraemos los nombres
	Nombre=$contact
	if  [[ $Nombre =~ "FN:" ]];
	then 
        let CONTADORN=CONTADORN+1
	nn=`echo $Nombre | cut -d ":" -f 2`
	echo "$CONTADORN; $nn" >> NOMBRES.txt
	
	#sleep 1
	fi

	Mail=$contact
	#Verificamos y extraemos los emails
	if [[ $Mail =~ "EMAIL;" ]];
	then
	let CONTADORM=CONTADORM+1
	mm=`echo $Mail | cut -d ":" -f 2`
	echo "$CONTADORM;  <$mm" >> MAILS.txt
	#echo $Mail
	#sleep 1
	fi

 done
	join NOMBRES.txt MAILS.txt | cut -d ";" -f 2 | sed 's/.com/.com>/' > Contactos.txt 
	rm NOMBRES.txt MAILS.txt
	
fi
