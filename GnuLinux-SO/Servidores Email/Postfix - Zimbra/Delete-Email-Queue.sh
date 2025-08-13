 
#!/bin/bash

#Exportamos al PATH los binarios de postfix (Zimbra).
PATH="$PATH:/opt/zimbra/postfix/sbin/"
export PATH

echo "Ingresa la cuenta de correo que quiere eliminar de la cola"
read CUENTA

#Generamos un Array Dinamico, almacena en cada casilla un ID de Correo.
ArrayCola=$( postqueue -p | grep $CUENTA | tr " " "*" | cut -d "*" -f 1 )
COUNTER=0

#Recorremos el Array y procesamos el contenido de cada casilla.
for i in ${ArrayCola[@]}
do
   #Eliminamos el Correo de la Cola.
   postsuper -d $i
   let COUNTER=COUNTER+1
done

echo $COUNTER