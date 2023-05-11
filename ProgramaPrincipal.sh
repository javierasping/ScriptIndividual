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

#Maquina donde se alojara la copia
IP_DAS=172.22.1.130


#1.Verificamos los parametros de entrada para obtener el origen de la copia
if [ $# -eq 0 ]; then
    directorio_origen_copia=$(pwd)
    echo "No se ha especificado ruta de origen para la copia de seguridad, se usará el directorio actual --> $directorio_origen_copia"
else
    directorio_origen_copia=$(echo $1)
    echo "Has especificado como origen de la copia de seguridad el directorio --> $directorio_origen_copia"
    while [ ! -d "$directorio_origen_copia" ]; do
        echo "El directorio $directorio_origen_copia no existe"
        read -p "Por favor, indica la ruta de un directorio válido: " directorio_origen_copia
    done
fi

#2.Comprobar si tenemos conexion con el DAS 
f_conexion_v2 $IP_DAS
if [ $? -eq 0 ]; then
    echo -e "Tienes conexion con $IP_DAS"
else
    echo -e "Para realizar la copia debes tener conexion con $IP_DAS"
fi

#Variables para la copia 
nombre_directorio_origen=$(basename "$directorio_origen_copia")
fecha_actual="$(date +%d-%m-%Y_%H-%M-%S)"
nombre_copia="copia_${nombre_directorio_origen}_${fecha_actual}.tar.gz"

#3.Realizamos la copia de seguridad 
hacer_copia_comprimida "$directorio_origen_copia"  "$nombre_copia"
if [ $? -eq 0 ]; then
    echo "Se ha creado una copia comprimida del directorio $directorio_origen_copia , se ha guardado con el nombre "$nombre_copia"."

else
    echo "Ocurrió un error al hacer la copia"

fi

#4.Comprobamos si la ruta esta montada en nuestro equipo 

destino=$(df -Th 2>/dev/null | grep -e '^'$1'' | awk '{print $7}')
    if [ -z "$destino" ]; then
        echo "Bien"
    else
        echo 'Malardo'
    fi

echo $destino
echo $1
echo 'Fin'

destino=$(ComprobarDestinoRemotoCopia $IP_DAS)
ehco $destino
echo 'FIN'