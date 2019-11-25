#!/bin/bash
# Declarar variables que se van a pedir al usuario
  let admin
  let pre_dominio
  let post_dominio
  let nom_csv
#
# Ahora pedimos al usuario los datos
read -p "Escriba el nombre del administrador: " admin
read -p "Escriba el nombre del dominio: " pre_dominio
read -p "Escriba la extensión del dominio: " post_dominio
read -p "Escriba el nombre del fichero CSV: " nom_csv
#
INPUT = nom_csv

OLDIFS=$IFS
IFS=','
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read num usuario unidad_organizativa
      do
        ################
      done < $INPUT
IFS=$OLDIFS


dn: uid=$usuario, ou=$unidad_organizativa,dc=$pre_dominio,dc=$post_dominio
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: $usuario
sn: $usuario
uid: $usuario
uidNumber: $num_user
gidNumber: $group_number
userPassword: $usuario
homeDirectory: /home/$usuario
loginShell: /bin/bash
gecos: $usuario
description: User account



exit 0
