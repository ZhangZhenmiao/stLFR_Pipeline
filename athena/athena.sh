thread=$1
bwa index ../metaspades/contigs.fasta
bwa mem -t $thread -C -p ../metaspades/contigs.fasta ../split_read_parsed_interleaved.fq | samtools sort -@ $thread -o align-reads.metaspades-contigs.bam
samtools index -@ $thread align-reads.metaspades-contigs.bam
athena-meta --config config.json