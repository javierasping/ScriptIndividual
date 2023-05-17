#!/bin/bash
#RestaurarCopias

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

#1.Verificamos que los parametros de entrada sean los correctos .

if [ $# -ne 2 ]; then
    echo "Para utilizar este script  debes proporcionar  el nombre  exacto de la copia y la ruta de destino donde quieres restaurarlo."
    echo "Uso: $0 <nombre_copia> <ruta_destino>"
    exit 1
fi

nombre_copia=$1
ruta_destino=$2

echo "1 OK ----------------------------------------------------------------------------------------------------"
#2.Comprobar si tenemos conexion con el DAS 
f_conexion_v2 $IP_DAS
if [ $? -eq 0 ]; then
    echo -e "Tienes conexion con $IP_DAS"
else
    echo -e "Para realizar la copia debes tener conexion con $IP_DAS"
fi
echo "2 OK ----------------------------------------------------------------------------------------------------"

#3 Comprobar que esta montada una unidad de red con la ip del NAS

Ruta_Recurso_Compartido=$(df -Th 2>/dev/null | grep -e '^'$IP_DAS'' | awk '{print $7}')
if [ $? -eq 0 ]; then
    if [ -e "$Ruta_Recurso_Compartido/$nombre_copia" ]; then
        echo "El archivo $nombre_copia existe en la ruta $Ruta_Recurso_Compartido."
    else
        echo "El archivo $nombre_copia no existe en la ruta $Ruta_Recurso_Compartido."
        exit 1
    fi
else
    echo -e "No se ha encontrafo ningun recurso compartido montado en el equipo"
    exit 1
fi


#4 Comprobar ruta de destino

if [ -d "$ruta_destino" ]; then
    echo "El directorio $ruta_destino  existe."
else
    echo "El directorio $ruta_destino no existe."
    exit 1 
fi


#5 Restaurar copia de seguridad 
cp "$Ruta_Recurso_Compartido/$nombre_copia" "$ruta_destino"
if [ $? -eq 0 ]; then
    tar -xzf "$ruta_destino/$nombre_copia" -C "$ruta_destino"
    if [ $? -eq 0 ]; then
        echo "Copia de seguridad restaurada exitosamente en $ruta_destino."
    else
        echo "Error al restaurar $nombre_copia en $ruta_destino."
        exit 1
    fi
else
    echo "Error al copiar $nombre_copia a $ruta_destino."
    exit 1
fi






