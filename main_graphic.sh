#!/bin/bash
#title           :script_CSV-LDIF
#description     :This script will add users to an active LDAP server using a .csv file as origin of users
#author		 :Leandro Galípolo Uriarte
#date            :20191126
#version         :1    
#usage		 :bash
#notes           :Install package dialoge | Have an active LDAP server
#bash_version    :4.1.5(1)-release
#===========================================================================================================

# Temp folder and variables
# Name some variables and create temporary folder and files to use
$(mkdir /tmp/parseador_ldif.$$)
OUTPUT=/tmp/parseador_ldif.$$/output.$$
INPUT=/tmp/parseador_ldif.$$/input.$$
let vAdmin
let vDominio
let vExtension
let vCSV
let vPassword
backtitle="Programa parseador"

# Delete temp files if program is closed or closes
trap "rm -dr /tmp/parseador_ldif*; exit" SIGHUP SIGINT SIGTERM

# Functions to be used in the script will be put here

# Admin input dialog
function show_inputAdmin(){
	dialog --title "[ A D M I N ]" \
	--backtitle "$backtitle" \
	--inputbox "Escriba el nombre del administrador del dominio " 8 60 "$vAdmin" 2>$INPUT
	vAdmin=$(cat $INPUT)
	ITEM="Admin"
}

# Domain input dialog
function show_inputDominio(){
	dialog --title "[ D O M I N I O ]" \
	--backtitle "$backtitle" \
	--inputbox "Escriba el nombre del administrador del dominio " 8 60 "$vDominio" 2>$INPUT
	vDominio=$(cat $INPUT)
	ITEM="Dominio"
}

# Extent input dialog
function show_inputExtension(){
	dialog --title "[ E X T E N S I O N ]" \
	--backtitle "$backtitle" \
	--inputbox "Escriba el nombre del administrador del dominio " 8 60 "$vExtension" 2>$INPUT
	vExtension=$(cat $INPUT)
	ITEM="Extension"
}

# CSV file selection dialog
function show_inputCSV(){
	dialog	--clear \
		--title "[-- C S V --]" \
		--backtitle "$backtitle" \
		--ok-label "Aceptar" \
		--cancel-label "Cancelar" \
		--fselect $HOME/ 14 48 2>$INPUT
        vCSV=$(cat $INPUT)
	ITEM="CSV"
}

# Commands to get the uidNumber of last added user.
# We will use it to be the prior to our first one.
function getLast(){
	ldapsearch -H ldap://$vDominio.$vExtension -x -LLL -b "dc=$vDominio,dc=$vExtension" "(objectClass=posixAccount)" uidNumber > /tmp/parseador_ldif.$$/uid_number_full.$$
	sed -i '/^$/d' /tmp/parseador_ldif.$$/uid_number_full.$$ #borrar lineas en blanco
	tail -1 /tmp/parseador_ldif.$$/uid_number_full.$$ | cut -d' ' -f2- > /tmp/parseador_ldif.$$/uid_number_alone.$$ #borrar primera palabra
	number_uid_last=$(cat /tmp/parseador_ldif.$$/uid_number_alone.$$)
	((number_uid_last=$number_uid_last+1))
}

# Loop to read each line in the CSV file
function ldif_loop(){
	IFS=';'
	[ ! -f $vCSV ] && { echo "$vCSV file not found"; exit 99; }
	while read num usuario unidad_organizativa descripcion
	      do
		password=$(slappasswd -h {SHA} -s "$usuario")
		echo "dn: uid=$usuario,ou=$unidad_organizativa,dc=$vDominio,dc=$vExtension" >> /tmp/parseador_ldif.$$/script_addUsers.ldif
		echo "objectClass: inetOrgPerson" >> /tmp/parseador_ldif.$$/script_addUsers.ldif
		echo "objectClass: posixAccount" >> /tmp/parseador_ldif.$$/script_addUsers.ldif
		echo "objectClass: shadowAccount" >> /tmp/parseador_ldif.$$/script_addUsers.ldif
		echo "cn: $usuario" >> /tmp/parseador_ldif.$$/script_addUsers.ldif
		echo "sn: $usuario" >> /tmp/parseador_ldif.$$/script_addUsers.ldif
		echo "uid: $usuario" >> /tmp/parseador_ldif.$$/script_addUsers.ldif
		echo "uidNumber: $number_uid_last" >> /tmp/parseador_ldif.$$/script_addUsers.ldif
		echo "gidNumber: 1" >> /tmp/parseador_ldif.$$/script_addUsers.ldif
		echo "userPassword: $password" >> /tmp/parseador_ldif.$$/script_addUsers.ldif
		echo "homeDirectory: /home/$usuario" >> /tmp/parseador_ldif.$$/script_addUsers.ldif
		echo "loginShell: /bin/bash" >> /tmp/parseador_ldif.$$/script_addUsers.ldif
		echo "gecos: $usuario" >> /tmp/parseador_ldif.$$/script_addUsers.ldif
		echo "description: $descripcion" >> /tmp/parseador_ldif.$$/script_addUsers.ldif
		printf "\n" >> /tmp/parseador_ldif.$$/script_addUsers.ldif
		((number_uid_last=$number_uid_last+1))
	      done <$vCSV
}

# Commands to get the first and the last .ldif entries
# Output is a dialog
function ldifShowFL(){
	$(cp /tmp/parseador_ldif.$$/script_addUsers.ldif /tmp/parseador_ldif.$$/first_last_entries_Before) # Copy to avoid using .ldif
	sed -i '/^$/d' /tmp/parseador_ldif.$$/first_last_entries_Before # Delete empty spaces or lines
	echo "[PRIMERA ENTRADA DEL .ldif]" >> /tmp/parseador_ldif.$$/first_last_entries
	$(head -14 /tmp/parseador_ldif.$$/first_last_entries_Before >> /tmp/parseador_ldif.$$/first_last_entries) # Show first entry
	echo "" >> /tmp/parseador_ldif.$$/first_last_entries
	echo "[ULTIMA ENTRADA DEL .ldif]" >> /tmp/parseador_ldif.$$/first_last_entries
	last_entryLDIF=$(tail -14 /tmp/parseador_ldif.$$/first_last_entries_Before >> /tmp/parseador_ldif.$$/first_last_entries) # Show last entry
	echo "" >> /tmp/parseador_ldif.$$/first_last_entries
	echo "[ENTRADAS TOTALES DEL .ldif]" >> /tmp/parseador_ldif.$$/first_last_entries
	$(grep -c ^$ /tmp/parseador_ldif.$$/script_addUsers.ldif >> /tmp/parseador_ldif.$$/first_last_entries)
	dialog  --clear \
		--title "[ L D I F ]" \
		--backtitle "$backtitle" \
		--exit-label "Atrás" \
		--textbox /tmp/parseador_ldif.$$/first_last_entries 40 70
}

# What to do when every variable is set
# Check if they are set and double check it before adding it to the LDAP
function continuar(){
	ITEM="Salir"
	if [ -z "$vAdmin" ]
		then
			error_nenough
	elif [ -z "$vDominio" ]
		then
			error_nenough
	elif [ -z "$vExtension" ]
		then
			error_nenough
	elif [ -z "$vCSV" ]
		then
			error_nenough
	else
		dialog  --clear \
			--title "[-- I N F O --]" \
			--backtitle "$backtitle" \
			--ok-label "Crear LDIF" \
			--msgbox "Nombre del admin: $vAdmin
			Dominio: $vDominio.$vExtension
			Ruta del CSV: $vCSV" 10 40
		exit_status=$?
		if [ $exit_status -eq 0 ]
			then
				dialog  --clear \
					--title "[ C O N F I R M A C I Ó N ]" \
					--backtitle "$backtitle" \
					--yes-label "Si" \
					--yesno "Confirme que desea continuar (no podrá deshacer cambios una vez añadido el LDIF)" 10 40
				answer_option=$?
				if  [ $answer_option -eq 0 ]
					then
						# Get last uidNumber to begin adding from that one
						getLast
						
						# Loop to create .ldif
						ldif_loop

						# Show first & last ldif entries
						ldifShowFL

						# Add entries to LDAP
						ldapadd -x -D cn=$vAdmin,dc=$vDominio,dc=$vExtension -W -f /tmp/parseador_ldif.$$/script_addUsers.ldif

						# Show last two added LDAP users
						slapcat | tail -44 > $OUTPUT
						dialog  --clear \
							--title "[ L A S T - C H E C K ]" \
							--backtitle "$backtitle" \
							--exit-label "Salir" \
							--textbox $OUTPUT 40 40
				fi
		fi
	fi
}

# If variables are not set and continuar happens, error return
function error_nenough() {
        dialog  --clear \
                --title "[-- I N F O --]" \
                --backtitle "$backtitle" \
                --msgbox "Falta información, comprueba las opciones" 7 40
}

# Main loop of the program
#------------------------------ MAIN MENU ------------------------------
while true; do
	dialog --backtitle "$backtitle" \
	--title "[ M E N U ]" \
	--default-item "$ITEM" \
	--menu "Seleccione las siguientes opciones:"	0 0 6 \
	Admin "Indique nombre del administrador el dominio" \
	Dominio "Indique nombre del servidor" \
	Extension "Indique nombre de la extensión del dominio" \
	CSV "Indique la ubicación del fichero .csv con los datos" \
	Continuar "Si ha rellenado todo, click aqui" \
	Salir "Salir del programa" 2>$INPUT

	selection=$(cat $INPUT)

  case $selection in
	Admin)
		show_inputAdmin;;
	Dominio)
		show_inputDominio;;
	Extension)
		show_inputExtension;;
	CSV)
    		show_inputCSV;;
	Continuar)
		continuar;;
	Salir)
		echo "Programa cerrado"; break;;
  esac
done
exit 0
