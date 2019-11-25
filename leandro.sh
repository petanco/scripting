#!/bin/bash
#DESCRIPTION script basico
#AUTHOR leandro galipolo
#dialog --menu "Programa -- Principal" 0 0 0 'Nombre' "con cebolla" 'Servidor' "sin cebolla" 3 "con piminetos"
usuario=Leandro
o_u=miCasa
uid_num=1
while [ $uid -lt 10 ]
      do
          echo "dn: uid=$usuario, ou=$o_u,dc=pre_dominio,dc=post_dominio" >> anadir_usuarios.ldif
          printf "\n" >> anadir_usuarios.ldif
          echo "cn: $usuario"  >> anadir_usuarios.ldif
          printf "\n" >> anadir_usuarios.ldif
          echo "sn: $usuario"  >> anadir_usuarios.ldif
          printf "\n" >> anadir_usuarios.ldif
          echo "uid_num: $uid"  >> anadir_usuarios.ldif
          printf "\n" >> anadir_usuarios.ldif
          ((uid_num=$uid_num+1))
      done
exit 0
# exit 0 indica que todo terminó bien
# este comentario se para ver si funcion
