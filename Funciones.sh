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
         echo -e "Con"
         else
         echo -e "Para ejecutar este script es necesario que disponga de conexion con $1"
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




#5. Función para ver si los paquetes están el sistema ( lvm2 mdadm dosfstool)

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

#8. Función para partcionar un disco como en la práctica 5.
function f_particionaundisco {
   sgdisk -n 0:0:+50M -c 0:efi $disco1
   sgdisk -n 0:0:+200M -c 0:boot $disco1
   sgdisk -n 0:0:+1G -c 0:raiz $disco1
   sgdisk -n 0:0:+700M -c 0:home $disco1
   sgdisk -n 0:0:+50M -c 0:swap $disco1
}

function f_particionaundisco_v2 {
   sgdisk -n 0:0:+50M -c 0:efi $disco1
   sgdisk -t 0:fd00 -n 0:0:+200M -c 0:boot $disco1
   sgdisk -t 0:fd00 -n 0:0:+1G -c 0:raiz $disco1
   sgdisk -t 0:fd00 -n 0:0:+700M -c 0:home $disco1
   sgdisk -n 0:0:+50M -c 0:swap $disco1
}


#9. Función para copiar la tabla de partciones en los discos 2,3,4.

function f_copiado_tablas_particiones {
    sgdisk --replicate=$disco2 $disco1
    sgdisk --replicate=$disco3 $disco1
    sgdisk --replicate=$disco4 $disco1
    sgdisk --randomize-guids $disco2
    sgdisk --randomize-guids $disco3
    sgdisk --randomize-guids $disco4
    partprobe
}

#10. Función para crear un RAID 5 con el 4 disco como spare.

function f_creacion_raid5 {
   mdadm --create /dev/md0 --level=5 --raid-devices=4 $disco1_2 $disco2_2 $disco3_2 $disco4_2
   mdadm --create /dev/md1 --level=5 --raid-devices=4 $disco1_3 $disco2_3 $disco3_3 $disco4_3
   mdadm --create /dev/md2 --level=5 --raid-devices=4 $disco1_4 $disco2_4 $disco3_4 $disco4_4
   partprobe
}


#11. Función para crear el volumen físico.
function f_creacion_del_volumen_fisico {
        pvcreate /dev/md0
        pvcreate /dev/md1
        pvcreate /dev/md2
}

#12.
function f_crecion_grupo_volumenes {
        vgcreate RM /dev/md0 /dev/md1 /dev/md2
}


#13. Función creamos los discos lógicos.
function f_creacion_volumen_logico {
         lvcreate -n VOL1 -L 1G RM
         lvcreate -n VOL2 -L 1G RM
         lvcreate -n VOL3 -L 1G RM
}

