#!/bin/bash
echo
echo "➡️ Comenzando pipeline de descontaminación de muestras..."
(printf -- '=%.0s' {1..50}; printf "\n\n")

input_urls=$1
#input_urls=data/urls
contaminants_url=$2
#contaminants_url=https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz

#Download all the files specified in data/filenames
echo "➡️ Descargando archivos fastq.gz..."
for url in $(cat $input_urls)
do
    bash scripts/download.sh $url data
done
(printf -- '=%.0s' {1..50}; printf "\n\n")

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
echo "➡️ Descargando archivo de contaminantes..."
bash scripts/download.sh $contaminants_url res yes "small nuclear"
(printf -- '=%.0s' {1..50}; printf "\n\n")

# Index the contaminants file
echo "➡️ Indexando archivo de contaminantes..."
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx
(printf -- '=%.0s' {1..50}; printf "\n\n")
(printf -- '=%.0s' {1..50}; printf "\n\n")

echo "➡️ Juntando archivos fastq.gz..."
list_of_sample_ids=$(ls data | grep fastq | cut -d "-" -f1 | sort | uniq)
# Merge the samples into a single file
for sid in $list_of_sample_ids
do
    bash scripts/merge_fastqs.sh data out/merged $sid
done

# run cutadapt for all merged files
echo "➡️ Eliminando adaptadores..."
mkdir -p log/cutadapt
mkdir -p out/trimmed
for fname in out/merged/*.fastq.gz
do
    cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
        -o out/trimmed/$(basename $fname .fastq.gz).trimmed.fastq.gz $fname >> log/cutadapt/$(basename $fname .fastq.gz).log
done
(printf -- '=%.0s' {1..50}; printf "\n\n")

# run STAR for all trimmed files
echo "➡️ Eliminando contaminantes..."
for fname in out/trimmed/*.fastq.gz
do
    # you will need to obtain the sample ID from the filename
    sid=$(basename $fname .trimmed.fastq.gz)
    echo $sid
    mkdir -p out/star/$sid
    STAR --runThreadN 4 --genomeDir res/contaminants_idx \
       --outReadsUnmapped Fastx --readFilesIn $fname \
       --readFilesCommand gunzip -c --outFileNamePrefix out/star/$sid/
done
(printf -- '=%.0s' {1..50}; printf "\n\n")

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in 
echo "➡️ Creando archivo de logs..."
for fname in out/trimmed/*.fastq.gz
do
    sid=$(basename $fname .trimmed.fastq.gz)
    echo "Logs from cutadapt and STAR for sample" $sid >> log/pipeline.log
    (printf -- '-%.0s' {1..50}; echo) >> log/pipeline.log
    printf "Logs from cutadapt\n\n" >> log/pipeline.log
    grep 'Reads with adapters' log/cutadapt/$sid.log >> log/pipeline.log
    grep 'Total basepairs' log/cutadapt/$sid.log >> log/pipeline.log
    (printf -- '-%.0s' {1..50}; echo) >> log/pipeline.log
    printf "Logs from STAR\n\n" >> log/pipeline.log
    grep 'Uniquely mapped reads %' out/star/$sid/Log.final.out >> log/pipeline.log
    grep '% of reads mapped to multiple loci' out/star/$sid/Log.final.out >> log/pipeline.log
    grep '% of reads mapped to too many loci' out/star/$sid/Log.final.out >> log/pipeline.log
    (printf -- '=%.0s' {1..50}; printf "\n\n") >> log/pipeline.log
done