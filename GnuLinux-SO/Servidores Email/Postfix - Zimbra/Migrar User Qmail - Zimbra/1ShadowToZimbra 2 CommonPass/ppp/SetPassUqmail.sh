#!/bin/bash
# Autor: Guillermo Elisondo
# Departamento :Servicio Tecnico SysAdmin
# Proposito: Setiamos una contraseña comun para los usuarios de una lista.
# Version: 1.0

#Contraseña seteada "123123"
#Variables
USERQ="UQmail2.txt"

cont=0
for USER in `cat $USERQ`
do
 
    #modificamos cuentas.
    usermod -p '$6$izJ.qGre$gie4CXGrzxkZp8y2KXdZqua4.ilr/yThQF0qI4vtfvxjcPbeGhQgl17Hxqiqyq9oM9xGnx6El5scQ2aFn6lyu.' $USER
    echo "User $USER -- Done"
    cont=$[cont+1]
done

echo "Se setiaron $cont Usuarios"

