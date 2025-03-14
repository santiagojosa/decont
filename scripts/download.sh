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
filename=$1
directory=$2
uncompress=$3
filter=$4

mkdir -p $directory

echo input $filename
echo output $directory
echo descomprimir $uncompress
echo filtrado $filter

while read -r line
do
	if [ "$uncompress" == yes ]
	then
		echo Descargando...
		wget $line -P $directory
		echo Archivo descargado
		echo Descomprimiendo...
		gunzip -k $directory/$(basename $line)
		echo Archivo descomprimido
	else
		echo Descargando...
		wget $line -P $directory
		echo Archivo descargado
	fi
done < $filename
