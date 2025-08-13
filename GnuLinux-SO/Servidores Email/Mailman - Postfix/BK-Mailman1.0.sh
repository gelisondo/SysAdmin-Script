#!/bin/bash
#Creador: gelisondo
#Version: 1.0
#Objetivo: Realizar un BK de los contactos y las listas como su configuración de mailman.
#Basados en comandos Mailman.

#comandos
CONFIG_LIST="/usr/sbin/config_list"
LIST_MEMBERS="/usr/sbin/list_members"
MKDIR="/bin/mkdir"
DIR="/var/backups/Mailman"
LOG="/var/log/BKmailman"
DATELOG=`date '+%d/%m/%Y %H:%M'`
DATE=`date '+%d-%m-%Y'`

if test ! -d $LOG
then
        mkdir $LOG
fi

if test ! -d $DIR
then
        mkdir $DIR
fi

BKDIR="$DIR/BK.$DATE"
mkdir $BKDIR

#Comenzamos tomando los nombres de la lista y los depocitamos en "vlistas"
#El loop correra tantas veces como listas que aya.
for vlistas in $(list_lists | tr -s " " | cut -d " " -f 2 | sed '1d')
do

        #Creamos un directorio con el nombre de la lista.
        $MKDIR $BKDIR/$vlistas
        #En el directorio, lista de miembros de la lista.
        $LIST_MEMBERS -f -o $BKDIR/$vlistas/$vlistas".txt" $vlistas
        if test $? = 0
        then
                echo "$DATELOG -- Ocurrio un error al intentar crear la lista de miembros" >> $LOG/bkerror
        fi
        #En el directorio, Configuración para esta lista.
        $CONFIG_LIST -o $BKDIR/$vlistas/$vlistas".cfg" $vlistas
        if test $? = 0
        then
                echo "$DATELOG -- Ocurrio un error al intentar descargar la configuración de la lista $vlistas" >> $LOG/bkerror
        fi

done

#Notas
#Con Sed '1d', le indicamos que borre la primera linea de la salida producida.