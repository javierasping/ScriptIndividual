#!/bin/bash
#RestaurarCopias

# Autor : Francisco Javier Cruces Doval
# Descripcion: Este script restaurara la copia de seguridad que indiques y la pondra a continuacion en el directorio que eligas . ./RestaurarCopia <nombre_copia> <ruta_destino>
# Repositorio: https://github.com/javierasping/ScriptIndividual

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






