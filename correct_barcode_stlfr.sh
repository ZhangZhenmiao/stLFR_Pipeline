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

mkdir tmp_sort
cat "$prefix".corrected_1.fq | paste -d '\t' - - - - | awk '{if($2 ~ /BX/){printf("%s\t%s\n",$2,$0);}else{printf("Z\t%s\n",$0);}}' | sort -T tmp_sort -t $'\t' -s -k1,1 | cut -f 2- | tr "\t" "\n" > "$prefix".corrected.sorted_1.fq &
cat "$prefix".corrected_2.fq | paste -d '\t' - - - - | awk '{if($2 ~ /BX/){printf("%s\t%s\n",$2,$0);}else{printf("Z\t%s\n",$0);}}' | sort -T tmp_sort -t $'\t' -s -k1,1 | cut -f 2- | tr "\t" "\n" > "$prefix".corrected.sorted_2.fq &
wait
rm -r "$prefix".corrected_1.fq "$prefix".corrected_2.fq tmp_sort

if [ $compress = "1" ]
then
    gzip "$prefix".corrected.sorted_1.fq &
    gzip "$prefix".corrected.sorted_2.fq &
    wait
fi
