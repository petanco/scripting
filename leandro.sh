#!/bin/bash
#DESCRIPTION script basico
#AUTHOR leandro galipolo
#dialog --menu "Programa -- Principal" 0 0 0 'Nombre' "con cebolla" 'Servidor' "sin cebolla" 3 "con piminetos"
let usuario
let o_u
uid = 0
while [ $uid -lt 10 ]
      DO
          echo "dn: uid=$usuario, ou=$o_u,dc=pre_dominio,dc=post_dominio" > anadir_usuarios.ldif
          printf "\n" >> anadir_usuarios.ldif
          echo "cn: $usuario"  >> anadir_usuarios.ldif
          printf "\n" >> anadir_usuarios.ldif
          echo "sn: $usuario"  >> anadir_usuarios.ldif
          printf "\n" >> anadir_usuarios.ldif
          echo "uid: $uid"  >> anadir_usuarios.ldif
          printf "\n" >> anadir_usuarios.ldif
          $uid++
      DONE
exit 0
# exit 0 indica que todo terminó bien
# este comentario se para ver si funciona
