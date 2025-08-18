#! /bin/bash
#Finalidad: Automatiza el cambio de dominio de nuestros usuarios
#Desarrollado: Guillermo Elisondo
#Versión: 3.1
#Ambiente: zimbra network 10.1.8

##Importante: Es necesario crear los dominios nuevos previamente, esta tarea no la contempla este scrit.

#1) Listaremos todos los usuarios de zimbra y lo volcaremos a un archivo de texto.
#Esto se realizara para despues de finalizar el trabajo con una cuenta, esta debe borrarse de dicho archivo con el comando Sed.
#2) Leemos el archivo linea por linea con un bucle for.
#3) Verificamos que no sean cuentas ya pasadas o del sistema zimbra.
#EJ: compras@enba.edu.uy,personal@enba.edu.uy, spam#sdlkfjß@enba.edu.uy
#Podemos utilizar un "case", o varios if,


###############################################################################################
###############################################################################################
#Variables
dominioDeInstalacion="tudominio.com"
NUEVODOMINIO="nuevodominio.com"

#Crear array para escribir varios dominios y escribir un solo codigo para generar los archivos. 
arrayDominios=("tudominio.com" "dominiolan.lan")
###############################################################################################
###############################################################################################

#Verificamos si el usuario es zimbra
who=`whoami`
if [ "$who" != "zimbra" ];
then
	echo
	echo "Please su to the zimbra user before running this script"
	echo
	exit 0
fi


#La primera ves que lo creamos agrega las cuentas del sistema que no se deben tocar.
#Podemos agregar otras cuetnas a mano, para evitar cambiar cuentas que deseamos que no migren.
if [ ! -f cuentasNoTocar.txt ]; then
	echo "Creando el archivo cuentasNoTocar.txt"
	touch cuentasNoTocar.txt
	zmprov -l gaa "$dominioDeInstalacion" | egrep  'galsync|spam|ham|virus' >> cuentasNoTocar.txt
fi

#Iteramos por cada dominio en el array
# y procesamos las cuentas de cada dominio.
for dominio in "${arrayDominios[@]}"; do

	#Se crea un archivo de texto con los usuarios de cada dominio.
	#Si el archivo ya existe y no está vacío, no lo volvemos a crear.
	
	# Verificar si el archivo ya existe y no está vacío
	if [ ! -s "listaDeUsuarios$dominio.txt" ]; then
		echo "Generamos el archivo con todas las cuentas de $dominio"
		touch "listaDeUsuarios$dominio.txt"
		zmprov -l gaa "$dominio" | egrep -v 'galsync|spam|ham|virus' >> "listaDeUsuarios$dominio.txt"
	fi
	
	#Iteramos por cada cuenta del archivo de texto.
	#Verificamos que no esté en el archivo de cuentasNoTocar.txt
	#Si no está, procedemos a cambiar el dominio de la cuenta.
	#Si ya existe una cuenta con el mismo nombre en el nuevo dominio, no se realiza
	for cuenta in $(cat listaDeUsuarios$dominio.txt);
	do

		#Buscamos la cuenta en el archivo cuentasNoTocar.txt
		BUSCAR=`grep $cuenta cuentasNoTocar.txt`
		

		#Si buscar tiene una cadena basía realiza la accion.
		if [[ -z $BUSCAR ]]; then

            # Esta variables es para comprobar si ya existe un usuario con el mismo nombre de cuenta en el nuevo dominio.		    
			cuentaNuevoDominio=$(echo "$cuenta" | sed  "s/$dominio/$NUEVODOMINIO/g")
			NOARTES=`zmprov -l gaa $NUEVODOMINIO | grep ^$cuentaNuevoDominio`

			# Verificamos que no exista este usuario en el nuevo dominio.
			if [[ -z $NOARTES ]]; then

				#Cambiar el dominio de la cuenta Vieja. ra - rename account - ok
				echo "Cambiando el dominio de la cuenta $cuenta a $cuentaNuevoDominio"
				#zmprov ra $cuenta $cuentaNuevoDominio
			      
  				#Creamos un aleas con el dominio anterior
				echo "Agregamos el alias de la cuenta $cuentaNuevoDominio a $cuenta"
				#zmprov aaa $cuentaNuevoDominio $cuenta
			    echo "$cuenta,$cuentaNuevoDominio" >> cuentasMigradas.csv
			else
			
				echo "No se pudo procesar la cuenta $cuentaNuevoDominio ya existe" >> NoSeProcesaronExistentes.txt
			
			fi
		fi
	done
done
