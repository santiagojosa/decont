# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).

input_directory=$1
output_directory=$2
sample_id=$3

mkdir -p $output_directory

cat $input_directory/$sample_id*.fastq.gz > $output_directory/$sample_id.fastq.gz
