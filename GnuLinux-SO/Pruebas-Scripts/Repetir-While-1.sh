#!/bin/bash

#COMPARACIONES NÚMERICAS
CONTADOR=0
while [[ $CONTADOR -lt 10 ]]; do
  echo "El valor es menor a 10"
  echo $CONTADOR
  let CONTADOR=CONTADOR+1
done
