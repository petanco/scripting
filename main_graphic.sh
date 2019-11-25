
#!/bin/bash
#Programa con interfaz grafica para el usuario %DUMB%
#Empty on purpose

#Store menu options selected by user:
INPUT=/tmp/menu.sh.$$

# trap and delete temp files
trap "rm $OUTPUT; rm $INPUT; exit" SIGHUP SIGINT SIGTERM

#Display output using msgbox
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

exit 0
