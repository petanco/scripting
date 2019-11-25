#!/bin/bash
# Declarar variables que se van a pedir al usuario
  let admin
  let pre_dominio
  let post_dominio
  let nom_csv
# Declaramos las funciones que vamos a utilizar despues
function ldif_loop() {
        password=$(slappasswd -h {SSHA} -s "$usuario")
        echo "dn: uid=$usuario,ou=$unidad_organizativa,dc=$pre_dominio,dc=$post_dominio" >> /tmp/parseador_ldif/script_addUsers.ldif
        printf "\n"
        echo "objectClass: inetOrgPerson" >> /tmp/parseador_ldif/script_addUsers.ldif
        printf "\n"
        echo "objectClass: posixAccount" >> /tmp/parseador_ldif/script_addUsers.ldif
        printf "\n"
        echo "objectClass: shadowAccount" >> /tmp/parseador_ldif/script_addUsers.ldif
        printf "\n"
        echo "cn: $usuario" >> /tmp/parseador_ldif/script_addUsers.ldif
        printf "\n"
        echo "sn: $usuario" >> /tmp/parseador_ldif/script_addUsers.ldif
        printf "\n"
        echo "uid: $usuario" >> /tmp/parseador_ldif/script_addUsers.ldif
        printf "\n"
        echo "uidNumber: $number_uid_last" >> /tmp/parseador_ldif/script_addUsers.ldif
        printf "\n"
        echo "gidNumber: 1" >> /tmp/parseador_ldif/script_addUsers.ldif
        printf "\n"
        echo "userPassword: $password" >> /tmp/parseador_ldif/script_addUsers.ldif
        printf "\n"
        echo "homeDirectory: /home/$usuario" >> /tmp/parseador_ldif/script_addUsers.ldif
        printf "\n"
        echo "loginShell: /bin/bash" >> /tmp/parseador_ldif/script_addUsers.ldif
        printf "\n"
        echo "gecos: $usuario" >> /tmp/parseador_ldif/script_addUsers.ldif
        printf "\n"
        echo "description: User account of $usuario" >> /tmp/parseador_ldif/script_addUsers.ldif
        printf "\n" >> /tmp/parseador_ldif/script_addUsers.ldif
}
#
# Ahora pedimos al usuario los datos
read -p "Escriba el nombre del administrador: " admin
read -p "Escriba el nombre del dominio: " pre_dominio
read -p "Escriba la extensión del dominio: " post_dominio
read -p "Escriba el nombre del fichero CSV: " nom_csv
#
# METEMOS EN LA VARIABLE number_uid_last EL VALOR DEL ULTIMO uidNumber para usarlo mas adelante 
rm -dr /tmp/parseador_ldif/
mkdir /tmp/parseador_ldif
ldapsearch -H ldap://vitoria.gasteiz -x -LLL -b "dc=vitoria,dc=gasteiz" "(objectClass=posixAccount)" uidNumber > /tmp/parseador_ldif/uid_number_full
sed -i '/^$/d' /tmp/parseador_ldif/uid_number_full
tail -1 /tmp/parseador_ldif/uid_number_full | cut -d' ' -f2- > /tmp/parseador_ldif/uid_number_alone
number_uid_last=$(cat /tmp/parseador_ldif/uid_number_alone)
rm /tmp/parseador_ldif/*
((number_uid_last=$number_uid_last+1))
################################################################################################
INPUT=$nom_csv
OLDIFS=$IFS
IFS=','
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read num usuario unidad_organizativa
      do
        ldif_loop
      done <$INPUT
IFS=$OLDIFS
exit 0
