#!/bin/bash
#Programa con interfaz grafica para el usuario %DUMB%
#Empty on purpose

# carpeta temporal y variables
$(rm -dr /tmp/parseador_ldif)
$(mkdir /tmp/parseador_ldif)
let vAdmin
let vDominio
let vExtension
let vCSV

# delete temp files if program closes
trap "rm -dr /tmp/parseador_ldif; exit" SIGHUP SIGINT SIGTERM

function show_input() {
	dialog --title "[ D O M I N I O ]" \
	--backtitle "Programa parseador" \
	--inputbox "Escrbia el nombre del administrador del dominio " 8 60 2>$vAdmin
}
# while menu dialog
DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

display_result() {
	dialog --title "$1" \
		--no.collapse \
		--msgbox "$result" 0 0
}

# loop for menu
while true; do
	exec 3>&1
	selection=$(dialog \
		--backtitle "Programa parseador" \
		--title "[ M E N U ]" \
		--clear \
		--cancel-label "Salir" \
		--menu "Seleccione las siguientes opciones:"	$HEIGHT $WIDTH 5 \
		"Admin" "Indique nombre del administrador el dominio" \
		"Servidor" "Indique nombre del servidor" \
		"Extensión" "Indique nombre de la extensión del dominio" \
		"CSV" "Indique la ubicación del fichero .csv con los datos" \
		"Continuar" "Si ha rellenado todo, click aqui" \
	2>&1 1>&3)
  exit_status=$?
  exec 3>&-
  case $exit_status in
    $DIALOG_CANCEL)
      clear
      echo "Programa terminado."
      exit
      ;;
    $DIALOG_ESC)
      clear
      echo "Programa cancelado." >&2
      exit 1
      ;;
  esac
  case $selection in
    0 )
      clear
      echo "Program terminated."

      ;;
    "Admin" )
      show_input
	;;
    "Dominio" )
      result=$(echo "Hostname: $HOSTNAME"; uptime)
      display_result "System Information"
      ;;
    "Extensión" )
      result=$(df -h)
      display_result "Disk Space"
      ;;
    "CSV" )
      result=$(echo "Hostname: $HOSTNAME"; uptime)
      display_result "System Information"
      ;;
    "Continuar" )
      if [[ $(id -u) -eq 0 ]]; then
        result=$(du -sh /home/* 2> /dev/null)
        display_result "Home Space Utilization (All Users)"
      else
        result=$(du -sh $HOME 2> /dev/null)
        display_result "Home Space Utilization ($USER)"
      fi
      ;;
  esac
done
exit 0
