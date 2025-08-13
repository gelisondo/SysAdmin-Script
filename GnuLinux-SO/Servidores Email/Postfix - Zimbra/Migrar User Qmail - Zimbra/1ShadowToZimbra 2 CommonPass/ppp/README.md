   Metodos y pasos de utilización de los script.

## 1) ShadowToZimbra.sh

 Se ejecuta en el viejo servidor "Qmail/Postfix".
 Es necesario editar este para ingresarle en la variable Dominio el nombre de tu dominio ej: "mercosur.edu.uy"
 Este scrip verifica los usuaios validos, comparando los usuarios que estan en /home y que contienen una structura Maildir. Estos ultimos son
comparados con los existantes en el /etc/shadow.
 Cuando la considencia es correca se le toma el nombre y la contraseña empcriptada y se genera un segundo scrip sh2ldap.sh .
 El ultimo scrip se ejecuta del lado del servidor de Zimbra "segundo host".

## 2) sh2ldap.sh
 Se ejecuta en nuevo server Zimbra.
 Se deve traer a este server el archivo UQmail2.txt.
 Al ejecutarlo pasamos todos los usuarios existentes a la base ldap zimbra con sus correspondientes contraseñas.

## 3) SetPassUqmail.sh
 Se ejecuta en el server viejo "Qmail/Postfix"
 Este lee el archivo de usuario normalizado UQmail2.txt que fue creado por el scrip ShadowToZimbra.sh.
 Por cada entrada de usuario de este archivo setea una contraseña comun "123123"

## 4) EmigramosQ-ZM.sh
 Se ejecuta en el nuevo server zimbra.
 Este recorre la lista de usuarios en UQmail2.txt y resetea los password de los usuarios zimbra a una contraseña comun igual a los reseteados del lado del server viejo "123123"
 Tras la ultima tarea comienza a sincronizar los correos con el software "imapsync", genera un log.
 Al culminar Genera un nuevo scrip "reset_passwords.sh" tomando las contraseñas originales y al ejecutarlo vuelve todo a la normalidad.
 
