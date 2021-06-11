#!/bin/bash
reads1=$1
reads2=$2
whitelist=$3
prefix=$4
type_bc=$5
threads=$6
compress=$7

set -e
extract_stlfr_bc.py $reads2 $prefix $type_bc
aln_stlfr_bc.sh $whitelist "$prefix"_bc1.fq "$prefix"_bc1_aln.sam $threads &
aln_stlfr_bc.sh $whitelist "$prefix"_bc2.fq "$prefix"_bc2_aln.sam $threads &
aln_stlfr_bc.sh $whitelist "$prefix"_bc3.fq "$prefix"_bc3_aln.sam $threads &
wait
rm "$prefix"_bc1.fq "$prefix"_bc2.fq "$prefix"_bc3.fq "$prefix"_bc1.fq.sai "$prefix"_bc2.fq.sai "$prefix"_bc3.fq.sai
correct_barcode_stlfr $whitelist "$prefix"_bc1_aln.sam "$prefix"_bc2_aln.sam "$prefix"_bc3_aln.sam $reads1 $reads2 2 $prefix.corrected_1.fq $prefix.corrected_2.fq
rm "$prefix"_bc1_aln.sam "$prefix"_bc2_aln.sam "$prefix"_bc3_aln.sam

awk '{printf("%s%s",$0,(NR%4==0)?"\n":"\0")}' "$prefix".corrected_1.fq | LANG=C sort -s -k 2,2 --parallel 10 -S 500m | tr "\0" "\n" > "$prefix".corrected.sorted_1.fq &
awk '{printf("%s%s",$0,(NR%4==0)?"\n":"\0")}' "$prefix".corrected_2.fq | LANG=C sort -s -k 2,2 --parallel 10 -S 500m | tr "\0" "\n" > "$prefix".corrected.sorted_2.fq &
wait
rm "$prefix".corrected_1.fq "$prefix".corrected_2.fq

if [ $compress = "1" ]
then
    gzip "$prefix".corrected.sorted_1.fq &
    gzip "$prefix".corrected.sorted_2.fq &
    wait
fi