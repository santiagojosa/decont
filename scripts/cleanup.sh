#!/bin/bash
# Elimina los archivos de las carpetas indicadas

if [ $# -eq 0 ]; then
    echo "Limpiando directorio de trabajo"
    echo $PWD

    #rm -r $PWD -v
else
    for dir in $@
    do
        echo "Limpiando $dir"
        echo $dir/*
        #rm -r $dir/* -v
    done
fi