#!/bin/bash
input_file=$1
output_dir=$2

# This script should index the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).

# The STAR command is provided for you. You should replace the parts surrounded
# by "<>" and uncomment it.

STAR --runThreadN 4 --runMode genomeGenerate --genomeDir $output_dir \
--genomeFastaFiles $input_file --genomeSAindexNbases 9
