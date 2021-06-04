#!/bin/bash
set -e
whitelist=$1
reads=$2
sam=$3
threads=$4
echo "bwa aln -t $threads $whitelist $reads > $reads.sai"
bwa aln -t $threads $whitelist $reads > $reads.sai
bwa samse $whitelist $reads.sai $reads> $sam
