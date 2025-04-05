#!/bin/bash

# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
# and *optionally*:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) contains the word "yes"
# - filter the sequences based on a word contained in their header lines:
#   sequences containing the specified word in their header should be **excluded**
#
# Example of the desired filtering:
#
#   > this is my sequence
#   CACTATGGGAGGACATTATAC
#   > this is my second sequence
#   CACTATGGGAGGGAGAGGAGA
#   > this is another sequence
#   CCAGGATTTACAGACTTTAAA
#
#   If $4 == "another" only the **first two sequence** should be output
url=$1
filename=$(basename $url)
directory=$2
uncompress=$3
filter=$4

echo from url: $url
echo filename: $filename
echo to directory: $directory/
if [ "$uncompress" == "yes" ]; then echo uncompress: $uncompress; fi
if [ -n "$filter" ]; then echo filter out containing: $filter; fi

mkdir -p $directory

echo ""
if [ -f data/$(basename $url) ]
    then
        echo "⚠️  Archivo $(basename $url) ya estaba descargado. No se vuelve a descargar"
    else
        echo "➡️  Descargando $filename..."
		wget $url -P $directory 
		echo ✅ Archivo descargado
fi

echo "➡️ Comprobando MD5 del archivo descargado..."
md5_online=$(curl -sS $url.md5 | cut -d' ' -f1) # md5sum of the online file
echo "MD5 online file: $md5_online"
md5_downloaded=$(md5sum $directory/$(basename $url) | cut -d' ' -f1) # md5sum of the downloaded file
echo "MD5 downloaded file: $md5_downloaded"
if [ "$md5_online" == "$md5_downloaded" ]
then
	echo ✅ MD5 check correcto
else
	echo ❌ Error en el MD5 check | tee /dev/stderr #se ve el mensaje y lo redirecciona el error a stderr
	exit 1
fi
(printf -- '-%.0s' {1..150}; echo) 

if [ "$uncompress" == "yes" ]
then
	echo "➡️  Descomprimiendo $filename..."
	gunzip -k $directory/$filename
	echo ✅ Archivo descomprimido
	(printf -- '-%.0s' {1..150}; echo)
fi

# Filtrado del archivo si se especifica una palabra en el header
if [ -n "$filter" ]
then
	unzipped_file=$(basename $filename .gz)
	echo 🔍 Filtrando $unzipped_file con patrón: $filter
	seqkit grep -r -n -p "$filter" $directory/$unzipped_file -v -o $directory/$unzipped_file.tmp || { echo "❌ Error al filtrar $filename"; exit 1; }
	# ejecuta seqkit grep con los argumentos:
	# -r: usa regexp
	# -n: busca en el nombre, no solo ID
	# -p: patrón a buscar
	# -v: invertir la búsqueda, para excluir
	# -o: archivo de salida
	# o muestra un mensaje de error y sale mediante error code 1
	mv $directory/$unzipped_file.tmp $directory/$unzipped_file
	echo "✅ Archivo filtrado"
fi