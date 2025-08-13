#!/bin/sh
#los rm estan comentados por seguridad por el momento
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
		if  test $capa -gt 100
		then

		#Elimina los archivos que le corespondan tal fecha 2005 asta 2008 
		ano=2005
		until [ $ano -eq 2009 ]
		do
	 		ls -lt --time-style=long-iso $line/Maildir/cur/ | grep "$ano-" > /dev/null
	 	   	if test $? -eq 0
    			then
 				echo "existen archivos del año $ano"
				#difinitiva borra lo que queremos
				ls -lt --time-style=long-iso $line/Maildir/cur/ | grep "$ano-" | awk '{print $8}' > delano.txt
				for lineano in $(cat delano.txt)
				do
					echo $line $linano
					ls -l $line/Maildir/cur/$lineano
				done
					rm delano.txt
			        
	  		else
			  	ano=`expr $ano + 1`
			fi
		done
			
		#Elimina archivos que vallan desde 2009-1 asta 2009-7
		ano=2009
		mes=1
		until [ $mes -eq 7 ]
		do
			ls -l --time-style=long-iso $line/Maildir/cur/ | grep "$ano-$mes-" > /dev/null
			if test $? -eq 0
	    		then
 				echo "existen archivos mes $ano $mes"
				#difinitiva borra lo que queremos
				ls -lt --time-style=long-iso $line/Maildir/cur/ | grep "$ano-$mes-" | awk '{print $8}' > delmes.txt
				for linemes in $(cat delmes.txt)
				do
					echo $line $linemes
					ls -l $line/Maildir/cur/$linemes
				done
					rm delmes.txt
			else
				mes=`expr $mes + 1`
	  		fi
		done
		echo $line
		fi	
        fi
done
##detalles:
#cortar nobres:
#esto "" ls -lt --time-style=long-iso | grep 2009 | cut -d ':' -f2 | cut -c 4- ""
#brinda el mismo resultado que esto "" ls -l --time-style=long-iso | awk '{print $8}' ""
