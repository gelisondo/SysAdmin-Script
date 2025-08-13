#!/bin/bash
#vamos cuentas por cunta.
#verificamos.

## Verificamos las cuentas que no se usan.

#Usamos la salida del comando ls como elementos de entrada para el for.
for line in `ls /home`
do
   if test -d /home/$line/Maildir/
   then
      #Creamos un array con la cantidad mails de que existen en cur   
      index=0
      for email in `ls /home/$line/Maildir/cur/`
      do
          mailsarray[$index]=$email
          index=$((index+1))
       done
       #recorremos el array para analizar todos los mails existentes         
       #esta variable solo la usaremos una ves en el until
       una=0
       #seteamos el indice para el array 0 
       ixa=0
       for ((i=0;i<${#mailsarray[@]};i++))
       {
           ANO=`ls -l --time-style=long-iso /home/$line/Maildir/cur/${mailsarray[$i]} | awk '{print $6}' | cut -d "-" -f 1 `
       #ya podemos ver todos los años, de los e-mailsarrayanos[$ixa]=$ANO
           arrayAnios[$ixa]=$ANO
           ixa=$((ixa+1))
       }
       aniosSinRepetir=$(tr ' ' '\n' <<< "${arrayAnios[@]}" | sort -u | tr '\n' ' ')
       echo "El array quedo con: "${aniosSinRepetir[*]}

 
           
# Recorrer el array y ver cuantos años iguales hay. Guardamos los años iguales
# Ya tenemos todo los años de los mails.
# Creamos carpetas para estos años con formato Maildir.
# le brindamos los mismos permisos y dueños del Maildir principal.
# Movemos los Mails des criminandolos por años.
   #idea:
#if ls -lt --time-style=long-iso  | awk '{print $6}' | cut -d "-" -f 1
#       then
#       
#
 #       fi
   fi
done
