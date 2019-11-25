#!/bin/bash
#Programa con interfaz grafica para el usuario %DUMB%
#Empty on purpose

#Store menu options selected by user:
INPUT=/tmp/menu.sh.$$

# trap and delete temp files
trap "rm $OUTPUT; rm $INPUT; exit" SIGHUP SIGINT SIGTERM

#Displat output using msgbox
# $1 -> set msgbox height
# $2 -> set msgbox width
# $3 -> set msgbox title
#
function display_output(){
	local h=$(1-10)
	local w=$(2-41)
	local t=$(3-Output)
	dialog --backtitle "Programa parseador" --title "$(t)" --clear --msgbox "$(<$OUTPUT)" $(h) $(w)
}
#

#Iinfinte loop
while true
do

### -- MAIN MENU -- ###
dialog --clear  --help-button --backtitle "Programa parseador" \
--title "[ M E N U -- I N I C I O ]" \
--menu "Lea atentamente las opciones, eliga y rellene \n\
cada apartado para poder continuar\n\
15 50 6 \
Admin "Indique el nombre del administrador del dominio" \
Servidor "Indique el nombre del dominio" \
Extension "Indique la extensión del dominio" \
CSV "Eliga el archivo CSV" \
Siguiente "Una vez rellenado todo venga aqui" \
Salir "Salir del script" 2>"${INPUT}"

menuitem=$(<"${INPUT}")

# make decision
case $menuitem in
	Admin) show_askAdmin;;
	Servidor) show_askServer;;
	Extension) show_askExtent;;
	CSV) show_askCSV;;
	Siguiente) show_next;;
	Salir) echo "¡Vuelva pronto!"; break;;
esac
done

# if temp files found, delete
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT


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
echo "" >> /tmp/parseador_ldif/first_last_entries
last_entryLDIF=$(tail -14 /tmp/parseador_ldif/first_last_entries_Before >> /tmp/parseador_ldif/first_last_entries)
echo "" >> /tmp/parseador_ldif/first_last_entries
$(cat /tmp/parseador_ldif/first_last_entries)
#end show first & last

# count entries to be added
$(grep -c ^$ /tmp/parseador_ldif/script_addUsers.ldif >> /tmp/parseador_ldif/total_entries)
echo $(cat /tmp/parseador_ldif/total_entries) " to be added"
#end count

#delete every temp filed used before exit
$(rm -dr /tmp/parseador_ldif/)
#
exit 0
