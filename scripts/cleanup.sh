#!/bin/bash
# Elimina los archivos de las carpetas indicadas

shopt -u dotglob # Mantengo archivos y carpetas ocultos (por ejemplo carpetas git)
shopt -s extglob # Habilito el uso de patrones extendidos

if [ $# -eq 0 ] # Elimina todo el directorio de trabajo
then
    echo "Limpiando directorio de trabajo"
    rm -rv "$PWD"/*
    exit 0
fi


for dir in "$@" # Para cada directorio pasado como argumento
do
    if [ "$dir" = "data" ] # Si el directorio es data
    then
        echo "Limpiando $dir excepto $dir/urls"
        rm -rv "$dir"/!(urls)
    elif [ "$(ls "$dir")" ] # Si el directorio no esta vacio
    then
        rm -rv "$dir"/*
    else # Si el directorio esta vacio
        echo "$dir esta vacio"
    fi
done