#!/bin/bash
#Fichero de funciones


#1. Función para comprobar que somos root.

function f_somosroot {
    if [ $UID -eq 0 ]; then
        return 0
    else
        echo "Para ejecutar este script es necesario que seas superusuario"
        return 1
    fi
}



#2. Función para comprobar conexión a internet.

function f_conexion {
         if ping -c 1 -q 8.8.8.8 > /dev/null; then
         return 0
         else
         echo -e "Para ejecutar este script es necesario que disponga de conexion a internet"
         return 1
         fi
 }

function f_conexion_v2 {
         if ping -c 1 $1 > /dev/null; then
            return 0
         else
            return 1
         fi
 }

#3. Función para comprobar que sistema operativo estamos utilizando.


function f_sistema_operativo_V2 {
    SO=$(lsb_release -d | awk '{print $2, $3}')
    if [[ $SO == "Debian GNU/Linux" ]]; then
        echo "El sistema operativo es Debian"
        return 2
    elif [[ $SO == "Rocky Linux" ]]; then
        echo "El sistema operativo es Rocky Linux"
        return 3
    else
        echo "Sistema operativo desconocido"
    fi
}




#4. Función para actualizar los repesitorios.

function f_actualización_repositorios_debian {
            sudo apt update -y >/dev/null 2>&1
            if [ $? -eq 0 ]; then
            echo -e “Se han actualizado los repositorios”
            else
            echo -e “No se han podido actualizar por repositorios”
            exit 1
            fi
}

function f_actualización_repositorios_rocky {
            sudo dnf update -y >/dev/null 2>&1
            if [ $? -eq 0 ]; then
            echo -e “Se han actualizado los repositorios”
            else
            echo -e “No se han podido actualizar por repositorios”
            exit 1
            fi
}




#5. Función para ver si los paquetes están el sistema 

function f_existepaquete_instala_debian {
        if sudo dpkg -s $1 >/dev/null 2>&1; then
           echo -e "El paquete $1 está instalado"
           return 0
        else
           echo -e "El paquete $1 no está instalado"
           apt install -y $1
           return 1
        fi
}


function f_existepaquete_instala_rocky {
        if sudo dpkg -s $1 >/dev/null 2>&1; then
           echo -e "El paquete $1 está instalado"
           return 0
        else
           echo -e "El paquete $1 no está instalado"
                sudo dnf $1
           return 1
        fi
}


#7. Función para comprobar el numero de dispositivos libres hay(min 4) , si no da error .
function f_detectadiscosvacios {
    local discos=()
    for i in {b..z}; do
        if sfdisk -d /dev/vd$i 2>&1 | grep -q "does not contain a recognized partition table"; then
            discos+=("/dev/vd$i")
        fi
        if [[ ${#discos[@]} -eq 4 ]]; then
            break
        fi
    done

    if [[ ${#discos[@]} -ne 4 ]]; then
        echo "Error: no se detectaron 4 discos vacíos" >&2
        return 1
    fi

    disco1="${discos[0]}"
    disco2="${discos[1]}"
    disco3="${discos[2]}"
    disco4="${discos[3]}"
}


#Comprueba si existe el directorio personal del usuario que ejecuta el script    
function ExisteDirectorioPersonalUsuario {
    if [ -d "$HOME" ]; then
        echo "El directorio personal del usuario $USER existe en: $HOME."
        return 0
    else
        echo "El directorio personal del usuario no existe."
        return 1
    fi
}



#Copia 
function hacer_copia_comprimida() {
    directorio_origen=$(echo $1)
    nombre_copia=$(echo $2)

    tar -czvf "$nombre_copia" "$directorio_origen" > /dev/null
    if [ $? -ne 0 ]; then
        return 1
    else
        return 0
    fi
}


# Comprobar si la ruta esta montada     (No)

# function ComprobarDestinoRemotoCopia() {
#     destino=$(df -Th 2>/dev/null | grep -e '^'$1'' | awk '{print $7}')
#     if [ -z "$destino" ]; then
#         return $destino
#     else
#         return 1
#     fi
# }


#
function MoverDestinoRemotoMontado {
    mv  "$1" "$2"
    if [ $? -ne 0 ]; then
        return 1
    else
        return 0
    fi
}




