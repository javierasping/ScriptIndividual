#!/bin/bash
#ProgramaPrincipal
# Autor : Francisco Javier Cruces Doval
# Descripcion: Este script realiza copias de seguridad introdicoendole un directorio por la linea de comandos ./ProgramaPrincipal ruta_absoluta . Posteriormente aprovechando un recurso de red NFS , Indicando la IP en la variable IP_DAS te subira las copias al mismo .
# Repositorio: https://github.com/javierasping/ScriptIndividual

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

echo "1 OK ----------------------------------------------------------------------------------------------------"
#2.Comprobar si tenemos conexion con el DAS 
f_conexion_v2 $IP_DAS
if [ $? -eq 0 ]; then
    echo -e "Tienes conexion con $IP_DAS"
else
    echo -e "Para realizar la copia debes tener conexion con $IP_DAS"
fi
echo "2 OK ----------------------------------------------------------------------------------------------------"

#Variables para la copia 
nombre_directorio_origen=$(basename "$directorio_origen_copia")
fecha_actual="$(date +%d-%m-%Y_%H-%M-%S)"
nombre_copia="copia_${nombre_directorio_origen}_${fecha_actual}.tar.gz"

#3. Función para comprobar que sistema operativo estamos utilizando.

f_sistema_operativo_V2
if [ $? -eq 2 ]; then
    f_actualización_repositorios_debian
    if [ $? -eq 0 ]; then
        for i in tar ; do
            f_existepaquete_instala_debian $i
        done
    fi
fi
if [ $? -eq 3 ]; then
    f_actualización_repositorios_rocky
    if [ $? -eq 0 ]; then
        for i in tar ; do
            f_existepaquete_instala_rocky $i
        done
    fi
fi
echo '3 ok --------------------------------------------------------------'



#4.Realizamos la copia de seguridad 
hacer_copia_comprimida "$directorio_origen_copia"  "$nombre_copia"
if [ $? -eq 0 ]; then
    echo "Se ha creado una copia comprimida del directorio $directorio_origen_copia , se ha guardado con el nombre "$nombre_copia"."

else
    echo "Ocurrió un error al hacer la copia"

fi
echo "4 OK ----------------------------------------------------------------------------------------------------"


#5.Comprobamos si la ruta esta montada en nuestro equipo . Si esta esta se movera la copia por el contrario devolvera un error .

destino=$(df -Th 2>/dev/null | grep -e '^'$IP_DAS'' | awk '{print $7}')
if [ -z "$destino" ]; then
    echo "No se ha encontrado un destino con la '$IP_DAS'"
else
    echo "Se copiara $nombre_copia a $destino"
    MoverDestinoRemotoMontado "$nombre_copia" "$destino"
    if [ $? -eq 0 ]; then
        echo -e "Se ha realizado la copia correctamente .Se encuentra en el directorio $destino con el nombre $nombre_copia"
    else
        echo -e "Ha habido un error al mover la copia a $destino"
    fi
fi

echo "5 OK ----------------------------------------------------------------------------------------------------"

echo $destino


