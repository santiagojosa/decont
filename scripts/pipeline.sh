#!/bin/bash
input_urls=$1
contaminants_url=$2

#Download all the files specified in data/filenames
for url in $(cat $input_urls)
do
    bash scripts/download.sh $url data
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
bash scripts/download.sh $contaminants_url res yes "small nuclear"

# Index the contaminants file
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx

list_of_sample_ids=$(ls data | grep fastq | cut -d "-" -f1 | sort | uniq)
# Merge the samples into a single file
for sid in $list_of_sample_ids
do
    bash scripts/merge_fastqs.sh data out/merged $sid
done

mkdir -p log/cutadapt
mkdir -p out/trimmed
# run cutadapt for all merged files
for fname in out/merged/*.fastq.gz
do
    cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
        -o out/trimmed/$(basename $fname .fastq.gz).trimmed.fastq.gz $fname >> log/cutadapt/$(basename $fname .fastq.gz).log
done

# run STAR for all trimmed files
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

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in 
echo "Logs from cutadapt and STAR for sample" $(basename $fname .trimmed.fastq.gz) >> log/pipeline.log
(printf -- '-%.0s' {1..50}; echo) >> log/pipeline.log
printf "Logs from cutadapt\n\n" >> log/pipeline.log
grep 'Reads with adapters' log/cutadapt/$(basename $fname .trimmed.fastq.gz).log >> log/pipeline.log
grep 'Total basepairs' log/cutadapt/$(basename $fname .trimmed.fastq.gz).log >> log/pipeline.log
(printf -- '-%.0s' {1..50}; echo) >> log/pipeline.log
printf "Logs from STAR\n\n" >> log/pipeline.log
grep 'Uniquely mapped reads %' out/star/$(basename $fname .trimmed.fastq.gz)/Log.final.out >> log/pipeline.log
grep '% of reads mapped to multiple loci' out/star/$(basename $fname .trimmed.fastq.gz)/Log.final.out >> log/pipeline.log
grep '% of reads mapped to too many loci' out/star/$(basename $fname .trimmed.fastq.gz)/Log.final.out >> log/pipeline.log
(printf -- '=%.0s' {1..50}; printf "\n\n") >> log/pipeline.log