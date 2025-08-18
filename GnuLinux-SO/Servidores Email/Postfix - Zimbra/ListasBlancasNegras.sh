#!/bin/bash
#Finalidad: Administrar las listas Negras y blancas de SpamAssassin
#Desarrollado: Guillermo Elisondo
#Versión: 2.9
#Ambiente: zimbra ose 8.8.15

BUSCAR=$(whiptail --title "Agregar Reglas a las listas Negras y Blancas de SpamAssassin" --inputbox "Ingresa la dirección de correo o dominio a ingresar en los baners" 10 60 3>&1 1>&2 2>&3)


#PATHSAUSER="/opt/zimbra/data/spamassassin/localrules/sauser.cf"
PATHSAUSER="/tmp/sauser.lc"
INICIAWHITE=`grep -b "# InWhiteList" $PATHSAUSER | cut -d ":" -f 1`
FINWHITE=`grep -b "# EndWhiteList" $PATHSAUSER | cut -d ":" -f 1`
INICIABLACK=`grep -b "# InBlackList" $PATHSAUSER | cut -d ":" -f 1`
FINBLACK=`grep -b "# EndBlackList" $PATHSAUSER | cut -d ":" -f 1`


menu=$(whiptail --title "MENU BOX" --menu "Ingresa la dirección de correo o dominio a ingresar en los baners" 15 60 4 \
"1" "Agregar una dirección a las listas negras" \
"2" "Agregar una dirección a las listas blancas" \
3>&1 1>&2 2>&3)


#Control de Existencía de dicho dominio o Cuentas
NBUSCAR=`grep -b $BUSCAR /tmp/sauser.lc | cut -d ":" -f 1`
if [ ! -z $NBUSCAR ];
then
    if (( $NBUSCAR > $INICIAWHITE )) && (( $NBUSCAR < $FINWHITE  ));
    then
        echo "Existe una regla Para las listas Blancas de la cuenta: $BUSCAR" > contenido_textbox
        whiptail --textbox contenido_textbox 40 150

    fi
    if (( $NBUSCAR > $INICIABLACK )) && (( $NBUSCAR < $FINBLACK ));
    then
        echo "Existe una regla pra las listas Negras de la cuenta: $BUSCAR" > contenido_textbox
        whiptail --textbox contenido_textbox 40 150

    fi
else
    # Comienza la segúnda fase.
    #echo "Procedemos a agregar dicho email"
    case $menu in
      1)
        #bloquear cuenta
        sed -i "s/# InBlackList/# InBlackList \nblacklist_from $BUSCAR/g" $PATHSAUSER
        zmamavisdctl restart
        #whiptail --msgbox "$BUSCAR" 20 78
      ;;
      2)
      #Cuentas de confianza
        sed -i "s/# InWhiteList/# InWhiteList \nwhitelist_from $BUSCAR/g" $PATHSAUSER
        zmamavisdctl restart
        #whiptail --msgbox "$BUSCAR" 20 78
      ;;
      *)
        echo "Opcion indevida"
        exit 0
      ;;
    esac
fi

#whiptail --msgbox "$result" 20 78



#Para identificar si una cuenta pertenece al grupo BlckList o WhiteList, podrimaos hacaear lo siguiente.
#Ingresar dos banderas para cada tipo una para iniciar y otra para finalizar4
#identificar
