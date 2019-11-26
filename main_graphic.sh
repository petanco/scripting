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

function show_inputAdmin(){
	dialog --title "[ A D M I N ]" \
	--backtitle "pars" \
	--inputbox "Escriba el nombre del administrador del dominio " 8 60 2>$OUTPUT
	vAdmin=$(cat $OUTPUT)
}

function show_inputDominio(){
	dialog --title "[ D O M I N I O ]" \
	--backtitle "parse" \
	--inputbox "Escriba el nombre del administrador del dominio " 8 60 2>$OUTPUT
	vDominio=$(cat $OUTPUT)
}

function show_inputExtension(){
	dialog --title "[ E X T E N S I O N ]" \
	--backtitle "parse" \
	--inputbox "Escriba el nombre del administrador del dominio " 8 60 2>$OUTPUT
	vExtension=$(cat $OUTPUT)
}

function show_inputCSV(){
	dialog	--title "[-- C S V --]" \
		--backtitle "parse" \
		--fselect $HOME/ 14 48 \ 2>$OUTPUT
        vCSV=$(cat $OUTPUT)
}
function continuar(){
	dialog  --clear \
		--title "[-- I N F O --]" \
		--backtitle "parse" \
		--ok-label "Crear LDIF" \
		--msgbox "INFO" 10 40
}

# loop for menu
while true; do
	dialog --backtitle "Parser" \
	--title "[ M E N U ]" \
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
		echo "HOLA";;
	Salir)
		echo "Programa cerrado"; break;;
  esac
done
exit 0
