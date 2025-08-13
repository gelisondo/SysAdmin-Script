#!/bin/bash

#Utilizamos en este  test verias herramientas y presentamos en pantalla los valores recomendados.
#Tools:
# dd,sysbench,hdparm

#limpiamos la pantalla
clear


 #Programacion
 #Declaracion de Funciones
 
#Test de CPU
function test_CPU ()
{
echo "#-----------------------------------------------------------------------------------------------------------------------------------------------------#"
echo ""

echo "Estresamos al CPU a calcular una cantidad elevada de numeros Primos, 20.000"
echo " "
echo "sysbench --test=cpu --cpu-max-prime=20000 run" 
sysbench --test=cpu --cpu-max-prime=20000 run 
echo " "

echo "Verificamos como se conporta con varios Trheads, subprocesos compitiendo y bloqueando parte de estos"
 echo " "
echo "sysbench --num-threads=64 --test=threads --thread-yields=100 --thread-locks=2 run"
echo " "
sysbench --num-threads=64 --test=threads --thread-yields=100 --thread-locks=2 run
echo " "
echo "#-----------------------------------------------------------------------------------------------------------------------------------------------------#"

}



#Test de Memoria
function test_memoria ()
{
echo "#-----------------------------------------------------------------------------------------------------------------------------------------------------#"
echo ""

echo "Testeamos la velocidad que lleva leer la memoria del sistema transfiriendo 100G con bloques de 1k"
echo " " 
echo "sysbench --test=memory --memory-block-size=1K --memory-scope=global --memory-total-size=100G --memory-oper=read run"
sysbench --test=memory --memory-block-size=1K --memory-scope=global --memory-total-size=100G --memory-oper=read run
echo ""

echo "Testeamos la velocidad de escritura en la memoria del sistema transfiriendo 100G con bloques de 1k"
echo " "
echo "sysbench --test=memory --memory-block-size=1K --memory-scope=global --memory-total-size=100G --memory-oper=write run"
echo " " 
sysbench --test=memory --memory-block-size=1K --memory-scope=global --memory-total-size=100G --memory-oper=write run
echo ""
echo "#-----------------------------------------------------------------------------------------------------------------------------------------------------#"
}

function test_inicio ()
{
    echo "Visualizamos la velosidad de inicio de Systemd"
    systemd-analyze time
}


#Testesos de Disco#
function test_disco ()
{
echo "======================================================================================================================================"
echo "                     #Uzamos  el comando dd para crear un archivo de 1G lleno de 0 y medir  la velocidad de escritura#"

echo "  "
echo "dd if=/dev/zero of=hddtest bs=8k count=128k"
echo "  "
dd if=/dev/zero of=hddtest bs=8k count=128k
rm hddtest

echo "======================================================================================================================================"



echo "======================================================================================================================================"
echo "                                   #Describimos  información de las particiones con el comando hdparm#"

echo "Visualizamos las particiones existentes con fdisk -l"
echo "  "
fdisk -l
echo "  "
echo "Ingrese la particion a analizar, ej: sda1 or sda2 or sdb3"
read PARTITION

echo "  "
echo "Verificamos cual es la velocidad que registra el fabricante para este disco"
echo "hdparm -I  /dev/$PARTITION | grep speed"
 hdparm -I  /dev/$PARTITION | grep speed
echo "  "

echo "Verificamos la velocidad de lectura del dispositivo -t, y la velocidad de lectura del CACHE de disco" 
echo "hdparm -tT /dev/$PARTITION"
echo "  "
 hdparm -tT /dev/$PARTITION

echo "======================================================================================================================================"

echo "  "

echo "======================================================================================================================================"
echo "                #Utilizamos la herramienta sysbench para crear un archivo de 10GB y hacer pruebas de lectura y escritura#"

echo "  "
echo "Creando el archivo de prueba"
echo "sysbench  --test=fileio --file-total-size=10G  prepare"
echo "  "

sysbench  --test=fileio --file-total-size=10G  prepare

echo "Corremos las pruebas sobre este archivo"
echo "sysbench --num-threads=16 --test=fileio --file-total-size=10G --file-test-mode=rndrw run"
echo "  "
sysbench --num-threads=16 --test=fileio --file-total-size=10G --file-test-mode=rndrw run

echo "  "
echo "limpiamos los residuos"
echo "sysbench --num-threads=16 --test=fileio --file-total-size=10G --file-test-mode=rndrw cleanup"
echo "  "
sysbench --num-threads=16 --test=fileio --file-total-size=10G --file-test-mode=rndrw cleanup
}


echo "Bienbenido al sistema de BestBench all in One"
echo "En este probaremos el performace del CPU, RAM y HDD"
sleep 1

echo "==========================================================Ingresa 1 para realizar un test de CPU==================================================" 
echo "==========================================================Ingresa 2 para realizar un test de RAM=================================================="
echo "==========================================================Ingresa 3 para realizar un test de HDD================================================="
echo "==========================================================Ingrese 4 para realizar un test de velocidad de inicio=========================="
echo "==========================================================Ingrese 5 para realizar todos los test ya listados====================================="
read TEST

case $TEST in
1)
 test_CPU
;;
2)
 test_memoria
;;
3)
 test_disco
;;
4)
 test_inicio
 
;;
5)
 test_inicio
 test_CPU
 test_memoria
 test_disco
 ;;
*)

  echo "debe ingresar una entrada valida 1,2,3"
;;
esac

echo "Deberia visualisar al Final un resumen analizando los datos obtenidos :SysAdmin"

