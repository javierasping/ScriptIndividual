#!/bin/bash
#ProgramaPrincipal

#P21 
#Implementa un programa para realizar copias de seguridad que se guardarán en un das.
# Se deberá comprobar que hay conexión con el das en el que se realizará dicha copia.
# Si se ejecuta sin ningún parámetro, de hará una copia completa del directorio de usuario que 
#lo está ejecutando, en caso contrario se comprobará si la ruta
# existe y se realizará la copia de dicho directorio. Si el directorio no existe, 
#dará la opción de indicar otro sin salir de la ejecución hasta que se indique uno correcto. 
#Las copias deben realizarse empacadas.





#Enlazar programa funcional con el de funciones
. ./Funciones.sh


if [ -d "$HOME" ]; then
  echo "El directorio personal del usuario existe en: $HOME"
else
  echo "El directorio personal del usuario no existe."
fi





#2.Comprobar si tenemos conexion con el DAS 
f_conexion_v2 8.8.8.8
if [ $? -ne 0 ]; then
    exit 1
fi
echo '2 ok --------------------------------------------------------------'

