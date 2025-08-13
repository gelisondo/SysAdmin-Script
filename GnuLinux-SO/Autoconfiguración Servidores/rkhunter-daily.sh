#!/bin/sh
#Soy Root?
IDUSER=`id -u`
#Compara que no sea igual a cero.
if [ $IDUSER -ne 0 ];
then
	echo "Debe ser una cuenta administrador para ejecutar este script"
	exit
fi

RKHUNTER=/usr/bin/rkhunter
REMAIL="admin@tudominio.lan"
test -x $RKHUNTER || exit 0

# source our config
. /etc/default/rkhunter

if [ -z "$NICE" ]; then
  NICE=0
fi

OUTFILE=`mktemp` || exit 1
rkhunter --update
/usr/bin/nice -n $NICE $RKHUNTER --cronjob --report-warnings-only --appendlog > $OUTFILE


#Eliminamos un error común, por no tener un binario en sus archivos .dat - En unbunt>
sed -i '/usr\/bin\/locate/d' $OUTFILE

#Eliminamos una alerta perteneciente a un servicios Xinetd, a rkhunter no le gustan >
sed -i '/xinetd.d\/check_mk/d' $OUTFILE

#Rkhunter se alerta por permitir acceso ssh por root, lo eliminamos ya que es utiliz>
sed -i '/PermitRootLogin/d' $OUTFILE
sed -i '/Warning\:\ The\ SSH\ and\ rkhunter/d' $OUTFILE
sed -i '/ALLOW_SSH_ROOT_USER/d' $OUTFILE

if [ -s "$OUTFILE" ]; then
  grep "Warning:" $OUTFILE >> /dev/null
  if [ $? -eq 0 ];
  then
   (
       echo "Subject : rkhunter $HOSTNAME - Daily report"
       echo ""
       cat $OUTFILE
    ) | sendmail $REMAIL
  fi
fi
rm -f $OUTFILE
