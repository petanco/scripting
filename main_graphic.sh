#!/bin/bash
#Programa con interfaz grafica para el usuario %DUMB%

# carpeta temporal y variables
$(mkdir /tmp/parseador_ldif.$$)
OUTPUT=/tmp/parseador_ldif.$$/output.$$
INPUT=/tmp/parseador_ldif.$$/input.$$
let vAdmin
let vDominio
let vExtension
let vCSV

# delete temp files if program closes
trap "rm -dr /tmp/parseador_ldif*; exit" SIGHUP SIGINT SIGTERM

# functions declare

function show_input(){
	dialog --title "[ D O M I N I O ]" \
	--backtitle "Programa parseador" \
	--inputbox "Escrbia el nombre del administrador del dominio " 8 60 2>$OUTPUT
}
# while menu dialog
HEIGHT=0
WIDTH=0

# loop for menu
while true; do
	dialog --backtitle "Programa parseador" \
	--title "[ M E N U ]" \
	--menu "Seleccione las siguientes opciones:"	$HEIGHT $WIDTH 6 \
	Admin "Indique nombre del administrador el dominio" \
	Servidor "Indique nombre del servidor" \
	Extension "Indique nombre de la extensión del dominio" \
	CSV "Indique la ubicación del fichero .csv con los datos" \
	Continuar "Si ha rellenado todo, click aqui" \
	Salir "Salir del programa" 2>$INPUT

	selection=$(cat $INPUT)

  case $selection in
    Admin)
	echo "admin";;
#	show_input;;
    Servidor)
	show_input;;
    Extension)
	show_input;;
    CSV)
      result=$(echo "Hostname: $HOSTNAME"; uptime)
      display_result "System Information"
      ;;
    Continuar)
	echo "HOLA"
      ;;
	Salir)
		echo "Programa cerrado"; break;;
  esac
done
exit 0
