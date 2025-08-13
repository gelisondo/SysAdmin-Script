#!/bin/sh

# bueno la idea es mostrar los MailDir con colores
# < 500 mb	 Green
# > 500 mb < 1000m Orangle
# > 1000 mb	 Red

#1 medir todas las casillas "tamaños"

echo "VERY DANGEROUSE se eliminaran mails"
echo "Si desea continuar presione ok"
read danger
if test $danger = "ok"
 then 
	echo "ok proseguir"
 else
	exit 5
fi
#guarda los nobres de las carpetas en un archivo de texto
ls > nombres.txt
#lee un archivo y guarda en una variable linea por linea
for line in $(cat nombres.txt)
do
	if test -d $line
	 then	
		#toma el tamaño y el nombre y guarda solo el tamaño
		capa=`(du -ms $line | awk '{print $1}' )`

		# Entra si es menor o igual a 500
		if  test $capa -le 500
		then
			echo "$capa ...... $line"
		
		fi

		# Entra si es mayor a 500 y menor que 1000
		if test $capa -ge 500 || $capa -le 1000
		then 
			echo $capa

		fi
        fi
done
rm nombres.txt
##detalles:
#cortar nobres:
#esto "" ls -lt --time-style=long-iso | grep 2009 | cut -d ':' -f2 | cut -c 4- ""
#brinda el mismo resultado que esto "" ls -l --time-style=long-iso | awk '{print $8}' ""
