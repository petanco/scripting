#!/bin/bash
# Declarar variables que se van a pedir al usuario
  let admin
  let pre_dominio
  let post_dominio
  let nom_csv
#
# Ahora pedimos al usuario los datos
read -p "Escriba el nombre del administrador: " admin
read -p "Escriba el nombre del dominio: " pre_dominio
read -p "Escriba la extensión del dominio: " post_dominio
read -p "Escriba el nombre del fichero CSV: " nom_csv
#
exit 0
