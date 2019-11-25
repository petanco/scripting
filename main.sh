#!/bin/bash
# Declarar variables que se van a pedir al usuario
  let admin
  let pre_dominio
  let post_dominio
  let nom_csv
# Declaramos las funciones que vamos a utilizar despues

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
sed -i '/^$/d' /tmp/parseador_ldif/uid_number_full #borrar lineas en blanco
tail -1 /tmp/parseador_ldif/uid_number_full | cut -d' ' -f2- > /tmp/parseador_ldif/uid_number_alone #borrar primera palabra
number_uid_last=$(cat /tmp/parseador_ldif/uid_number_alone)
rm /tmp/parseador_ldif/*
((number_uid_last=$number_uid_last+1))
# end_last_uidNumber

# loop to create .ldif
INPUT=$nom_csv
IFS=';'
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read num usuario unidad_organizativa descripcion
      do
        password=$(slappasswd -h {SHA} -s "$usuario")
        echo "dn: uid=$usuario,ou=$unidad_organizativa,dc=$pre_dominio,dc=$post_dominio" >> /tmp/parseador_ldif/script_addUsers.ldif        
        echo "objectClass: inetOrgPerson" >> /tmp/parseador_ldif/script_addUsers.ldif       
        echo "objectClass: posixAccount" >> /tmp/parseador_ldif/script_addUsers.ldif        
        echo "objectClass: shadowAccount" >> /tmp/parseador_ldif/script_addUsers.ldif       
        echo "cn: $usuario" >> /tmp/parseador_ldif/script_addUsers.ldif       
        echo "sn: $usuario" >> /tmp/parseador_ldif/script_addUsers.ldif        
        echo "uid: $usuario" >> /tmp/parseador_ldif/script_addUsers.ldif        
        echo "uidNumber: $number_uid_last" >> /tmp/parseador_ldif/script_addUsers.ldif        
        echo "gidNumber: 1" >> /tmp/parseador_ldif/script_addUsers.ldif        
        echo "userPassword: $password" >> /tmp/parseador_ldif/script_addUsers.ldif        
        echo "homeDirectory: /home/$usuario" >> /tmp/parseador_ldif/script_addUsers.ldif     
        echo "loginShell: /bin/bash" >> /tmp/parseador_ldif/script_addUsers.ldif        
        echo "gecos: $usuario" >> /tmp/parseador_ldif/script_addUsers.ldif
        echo "description: $descripcion" >> /tmp/parseador_ldif/script_addUsers.ldif
        printf "\n" >> /tmp/parseador_ldif/script_addUsers.ldif
        ((number_uid_last=$number_uid_last+1))
      done <$INPUT
# loop end

# show first & last ldif entries
$(cp /tmp/parseador_ldif/script_addUsers.ldif /tmp/parseador_ldif/first_last_entries_Before)
sed -i '/^$/d' /tmp/parseador_ldif/first_last_entries_Before
first_entryLDIF=$(head -14 /tmp/parseador_ldif/first_last_entries_Before >> /tmp/parseador_ldif/first_last_entries)
last_entryLDIF=$(tail -14 /tmp/parseador_ldif/first_last_entries_Before >> /tmp/parseador_ldif/first_last_entries)
$(cat /tmp/parseador_ldif/first_last_entries)
exit 0
