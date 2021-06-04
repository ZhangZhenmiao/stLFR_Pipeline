#!/bin/bash
reads1=$1
reads2=$2
whitelist=$3
prefix=$4
threads=$5
script_dir=$6
type_bc=$7

set -e

if [ ! -f split.corrected_1.fq ]
then
    gzip -dc $reads1 > reads1.fq &
    gzip -dc $reads2 > reads2.fq &
    wait
    reads1=reads1.fq
    reads2=reads2.fq
    $script_dir/extract_stlfr_bc.py $reads2 $prefix $type_bc
    $script_dir/aln_stlfr_bc.sh $whitelist "$prefix"_bc1.fq "$prefix"_bc1_aln.sam $threads &
    $script_dir/aln_stlfr_bc.sh $whitelist "$prefix"_bc2.fq "$prefix"_bc2_aln.sam $threads &
    $script_dir/aln_stlfr_bc.sh $whitelist "$prefix"_bc3.fq "$prefix"_bc3_aln.sam $threads &
    wait
    $script_dir/correct_barcode_stlfr $whitelist "$prefix"_bc1_aln.sam "$prefix"_bc2_aln.sam "$prefix"_bc3_aln.sam $reads1 "$prefix"_reads_only.fq 2 $prefix.corrected_1.fq $prefix.corrected_2.fq
    rm "$prefix"_reads_only.fq
fi

if [ ! -d temp ]
then
    mkdir temp
fi
if [ ! -f $prefix.corrected.interleaved.fq ]
then
    seqtk mergepe $prefix.corrected_1.fq $prefix.corrected_2.fq > $prefix.corrected.interleaved.fq
fi
if [ ! -f split_read_parsed_interleaved.fq ]
then
    cat $prefix.corrected.interleaved.fq | paste -d '\t' - - - - - - - - | awk '{if($2 ~ /BX/){printf("%s\t%s\n",$2,$0);}else{printf("Z\t%s\n",$0);}}' | LANG=C sort -t $'\t' -k1,1 -T temp/ | cut -f 2- | tr "\t" "\n" > split_read_parsed_interleaved.fq
fi
rm -r temp $prefix.corrected.interleaved.fq $prefix.corrected_1.fq $prefix.corrected_2.fq
