#!/bin/bash

echo "Mostraresmo diferentes formas de utilizar el bucle for en bash scripts"


  echo "#Secuencias.. Esta seguira un patron finito"
  echo "#El for recorrera la cantidad de elementos que se encuentrar despues del 'in' guardandolos en la variable i."
  echo "#Estos los valores son introducido a mano."
  for a in 1 2 3 4 6 E;
  do
    echo $a;
  done

echo ""
echo "Secuencia utilizando un comando esterno seq"
echo "Utilizamos el comando ( seq 1 9 ) para generar todos los valores restates"
for b in `seq 1 19`;
do
  echo "Secuencia número: $b"
done
echo ""
echo ""

echo "#Utilizamos el caracter sustitución de comandos para obtener la entrada."
for c in `ls $HOME`;
do
  echo "Elementos encontrados: $c"
done

echo ""
echo "#Leemos archivos de textos para recorrer su contenido."
for e in `cat /etc/passwd`;
do
  echo "Entrada de usuarios: $e"
done
