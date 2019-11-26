#!/bin/bash
#Script with user interface to automatically add users to LDAP from a curated csv

# Temp folder and variables
$(mkdir /tmp/parseador_ldif.$$)
OUTPUT=/tmp/parseador_ldif.$$/output.$$
INPUT=/tmp/parseador_ldif.$$/input.$$
let vAdmin
let vDominio
let vExtension
let vCSV
let vPassword
backtitle="Programa parseador"

# delete temp files if program closes
trap "rm -dr /tmp/parseador_ldif*; exit" SIGHUP SIGINT SIGTERM

# functions declare
function show_inputAdmin(){
	dialog --title "[ A D M I N ]" \
	--backtitle "$backtitle" \
	--inputbox "Escriba el nombre del administrador del dominio " 8 60 2>$INPUT
	vAdmin=$(cat $INPUT)
	ITEM="Admin"
}

function show_inputDominio(){
	dialog --title "[ D O M I N I O ]" \
	--backtitle "$backtitle" \
	--inputbox "Escriba el nombre del administrador del dominio " 8 60 2>$INPUT
	vDominio=$(cat $INPUT)
	ITEM="Dominio"
}

function show_inputExtension(){
	dialog --title "[ E X T E N S I O N ]" \
	--backtitle "$backtitle" \
	--inputbox "Escriba el nombre del administrador del dominio " 8 60 2>$INPUT
	vExtension=$(cat $INPUT)
	ITEM="Extension"
}

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

function show_inputPassword(){
	dialog --title "[ P A S S W O R D ]" \
	--backtitle "$backtitle" \
	--inputbox "Escriba el nombre del administrador del dominio " 8 60 2>$INPUT
	vAdmin=$(cat $INPUT)
}

function continuar(){
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
						# get last uidNumber of ldap to start from that one
							ldapsearch -H ldap://$vDominio.$vExtension -x -LLL -b "dc=$vDominio,dc=$vExtension" "(objectClass=posixAccount)" uidNumber 2> $OUTPUT
							sed -i '/^$/d' $OUTPUT #borrar lineas en blanco
							tail -1 $OUTPUT | cut -d' ' -f2- 2> $OUTPUt #borrar primera palabra
							number_uid_last=$(cat $OUTPUT)
							((number_uid_last=$number_uid_last+1))
						# end_last_uidNumber

						# loop to create .ldif
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
						# loop end
						# show first & last ldif entries
							$(cp /tmp/parseador_ldif.$$/script_addUsers.ldif /tmp/parseador_ldif.$$/first_last_entries_Before)
							sed -i '/^$/d' /tmp/parseador_ldif.$$/first_last_entries_Before
							echo "[PRIMERA ENTRADA DEL .ldif]" >> /tmp/parseador_ldif.$$/first_last_entries
							$(head -14 /tmp/parseador_ldif.$$/first_last_entries_Before >> /tmp/parseador_ldif.$$/first_last_entries)
							echo "" >> /tmp/parseador_ldif.$$/first_last_entries
							echo "[ULTIMA ENTRADA DEL .ldif]" >> /tmp/parseador_ldif.$$/first_last_entries
							last_entryLDIF=$(tail -14 /tmp/parseador_ldif.$$/first_last_entries_Before >> /tmp/parseador_ldif.$$/first_last_entries)
							echo "" >> /tmp/parseador_ldif.$$/first_last_entries
							echo "[ENTRADAS TOTALES DEL .ldif]" >> /tmp/parseador_ldif.$$/first_last_entries
							# count entries to be added
								$(grep -c ^$ /tmp/parseador_ldif.$$/script_addUsers.ldif >> /tmp/parseador_ldif.$$/first_last_entries)					
							#end count
						#end show first & last
						dialog  --clear \
							--title "[ L D I F ]" \
							--backtitle "$backtitle" \
							--exit-label "Atrás" \
							--textbox /tmp/parseador_ldif.$$/first_last_entries 40 70

						
				fi
		fi
	fi
}

function error_nenough() {
        dialog  --clear \
                --title "[-- I N F O --]" \
                --backtitle "$backtitle" \
                --msgbox "Falta información, comprueba las opciones" 7 40
}

# loop for menu
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
