
#!/bin/bash
#Programa con interfaz grafica para el usuario %DUMB%
#Empty on purpose

#Dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

# Temporary file
tmp_file=$(mktemp -d "${TMPDIR:-/tmp/}$(basename $0).XXXXXXXXXXXX")

# trap and delete temp files on exit
trap "rm -f $OUTPUT" 0 1 2 5 15

# Generate dialog box
dialog --title "Parseador" \
	--clear \
	--inputbox "Hola, prueba" 16 51 2> $tmp_file
exit 0
