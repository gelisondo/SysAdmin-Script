#!/bin/bash
#Para que funcione esto primero devimos extraer todas las contraseñas originales y agregar esos usuarios con los scriopts anteriores.
#
# imapsyncrun.sh. Script to migrate imap mailboxes under the account migrate1
DATE=`date +%m%d%y_%H:%M` 
LOGFILE="imapsync.log"
USERQ="UQmail2.txt"
DOMINIO="@tecnicos.lan"
PASSWD="123123"
HOST1="enba1.enba.edu.uy"
HOST2="zenba.tecnicos.lan" 
LUGAR=`pwd`

echo "IMAPSync starting..  $DATE" >> $LOGFILE 

# Iniciamos un loop linea por linea, asta llegar al final, tomamos de este el contenido de la linea "Nombre de Usuario"
for USERNAME in `cat $USERQ`
do
#Modificamos la cuenta actual y le cambiamos el password por uno temporal, este es el mismo que estara en el otro servidor.
zmprov ma $USERNAME$DOMINIO userPassword '{crypt}$6$izJ.qGre$gie4CXGrzxkZp8y2KXdZqua4.ilr/yThQF0qI4vtfvxjcPbeGhQgl17Hxqiqyq9oM9xGnx6El5scQ2aFn6lyu.'
echo $USERNAME$DOMINIO

# Then migrate:
imapsync --buffersize 8192000 --nosyncacls --logfile $LUGAR/log/$USERNAME-$DATE --subscribe --syncinternaldates --host1 $HOST1 --user1 $USERNAME  --password1 $PASSWD --host2 $HOST2 --user2 $USERNAME$DOMINIO --password2 $PASSWD


echo Done with $USERNAME on $DATE >> $LOGFILE

done

# Change the password back to the encrypted one on file.
echo "#!/bin/bash" >  reset_passwords.sh
grep "zmprov ma" sh2ldap.sh >> reset_passwords.sh
chmod +x reset_passwords.sh
./reset_passwords.sh

echo "" >> $LOGFILE
echo "IMAPSync Finished..  $DATE" >> $LOGFILE
echo "------------------------------------" >> $LOGFILE 

