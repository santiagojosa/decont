#!/bin/bash
# Elimina los archivos de las carpetas indicadas

shopt -u dotglob # Mantengo archivos y carpetas ocultos (por ejemplo carpetas git)
shopt -s extglob # Habilito el uso de patrones extendidos

if [ $# -eq 0 ] # Elimina todo el directorio de trabajo
then
    echo "Eliminando todo el contenido del directorio de trabajo"
    rm -rv "$PWD"/*
    exit 0
fi


for dir in "$@" # Para cada directorio pasado como argumento
do
    if [ "$dir" = "data" ] && [ $(ls -1 "$dir" | wc -l) -gt 1 ] # Si el directorio es data y tiene mas que el archivo urls
    then
        echo "Limpiando $dir excepto $dir/urls"
        rm -rv "$dir"/!(urls)
    elif [ "$dir" != "data" ] && [ "$(ls "$dir")" ] # Si el directorio no es data y no esta vacio
    then
        echo "Limpiando $dir"
        rm -rv "$dir"/*
    else # Si el directorio esta vacio
        echo "$dir esta vacio"
    fi
done