#!/bin/bash

#Nos situamos en la carpeta a trabajar.
#Buscamos en esta en esta los archivos ".vdi" existentes, tomamos su ruta y los convertimos  en archivos raw, para posteriormente convertirlo en qcow2 en extención .img .
#Notificamos cada archivo convertido con exito.


#Dependencias:
#virtualbox qemu-utils

#Convertimos archivo VDI a Raw
#VBoxManage clonehd --format RAW sistema_virtualizado.vdi sistema_virtualizado.raw

#Convertmos archivos Raw a qmcow2
#qemu-img convert -f raw sistema_virtualizado.raw -O qcow2 sistema_virtualizado.img

#ejecutamos un comando al encontrar el archivo.
#find . -type f -exec chmod 674 {} \;
#find /home/kaneda/ -name *.vdi -exec ln -vs {} {}.link \;

echo "Ingrese el nombre del usuarios siguientes:"
ls /home
read usuario
uhome=`grep $usuario /etc/passwd | cut -d ":" -f 6`
if ! test -d $uhome
then
  echo "El home existe: $uhome"
  exit 0
fi
for archivo in `find $uhome -name *.vdi`
do
   ls -l $archivo
  
done
