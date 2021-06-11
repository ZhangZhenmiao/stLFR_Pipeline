#!/bin/bash
## requirements
# perl
# libz
# megahit
# bwa
# samtools
# athena-meta
# seqtk

## usage
# bash run_pipe.sh <path_to_stlfr_read1> <path_to_stlfr_read2> <number_of_threads> <path_to_stLFR_Pipe_folder> <output_dir> <barcode_type>

## pipe init
set -e
case $1 in
  /*) read1=$1;;
  *) read1=$PWD/$1;;
esac
case $2 in
  /*) read2=$2;;
  *) read2=$PWD/$2;;
esac
thread=$3
case $4 in
  /*) script_dir=$4;;
  *) script_dir=$PWD/$4;;
esac
case $5 in
  /*) out_dir=$5;;
  *) out_dir=$PWD/$5;;
esac
type_bc=$6

# step 0 enter output_dir
if [ ! -d "$out_dir" ]
then
    mkdir $out_dir
fi
cd $out_dir

# step 2 transform barcode
if [ ! -f "$out_dir/split.corrected.sorted_1.fq" ]
then
    correct_barcode_stlfr.sh $read1 $read2 $script_dir/white_list_stlfr_barcode.fa split $type_bc $thread 0
fi

if [ ! -f "$out_dir/split_read_parsed_interleaved.fq" ]
then
  seqtk mergepe $out_dir/split.corrected.sorted_1.fq $out_dir/split.corrected.sorted_2.fq > $out_dir/split_read_parsed_interleaved.fq
fi

# step 3 megahit
if [ ! -d "$out_dir/megahit" ]
then
    megahit --12 $out_dir/split_read_parsed_interleaved.fq -t $thread -m 0.99 -o $out_dir/megahit
fi

# step 4 athena-meta
if [ ! -d "$out_dir/athena" ]
then
    mkdir athena
fi
cd athena
echo 'thread=$1' > athena.sh
if [ ! -f "align-reads.megahit-contigs.bam" ]
then
    echo 'bwa index ../megahit/final.contigs.fa' >> athena.sh
    echo 'bwa mem -t $thread -C -p ../megahit/final.contigs.fa ../split_read_parsed_interleaved.fq | samtools sort -@ $thread -o align-reads.megahit-contigs.bam' >> athena.sh
    echo 'samtools index -@ $thread align-reads.megahit-contigs.bam' >> athena.sh
fi
echo 'athena-meta --config config.json' >> athena.sh
echo '{' > config.json
echo '  "ctgfasta_path" :      "../megahit/final.contigs.fa",' >> config.json
echo '  "reads_ctg_bam_path" : "align-reads.megahit-contigs.bam",' >> config.json
echo '  "input_fqs" :          "../split_read_parsed_interleaved.fq",' >> config.json
echo '  "cluster_settings": {' >> config.json
echo '      "cluster_type": "multiprocessing",' >> config.json
echo '      "processes": '"$(($thread/3))" >> config.json
echo '  }' >> config.json
echo '}' >> config.json
bash athena.sh $thread
