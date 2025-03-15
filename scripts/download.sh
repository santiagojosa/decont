#!/usr/bin/bash

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
filepath=$1
filename=$(basename $filepath)
directory=$2
uncompress=$3
filter=$4

mkdir -p $directory

echo input $filename
echo output $directory
echo descomprimir $uncompress
echo filtrado $filter

if [ "$uncompress" == yes ]
then
	echo Descargando...
	wget $filepath -P $directory 
	echo Archivo descargado
	echo Descomprimiendo...
	gunzip -k $directory/$filename
	echo Archivo descomprimido
else
	echo Descargando...
	wget $filepath -P $directory
	echo Archivo descargado
fi

# Filtrado del archivo si se especifica una palabra en el header
if [ -n "$filter" ]
then
	echo 🔍 Filtrando $directory/$filename con patrón: $filter
	output_file=$directory/filtered_$(basename $filename .gz)
	seqkit grep -r -n -p "$filter" $directory/$filename -v -o $output_file || { echo "❌ Error al filtrar $filename"; exit 1; }
	# ejecuta seqkit grep con los argumentos:
	# -r: usa regexp
	# -n: busca en el nombre, no solo ID
	# -p: patrón a buscar
	# -v: invertir la búsqueda, para excluir
	# -o: archivo de salida
	# o muestra un mensaje de error y sale mediante error code 1
	echo "✅ Archivo filtrado: $output_file"
fi