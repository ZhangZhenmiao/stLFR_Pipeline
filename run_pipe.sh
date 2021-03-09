## requirements
# perl
# libz
# spades
# bwa
# samtools
# athena-meta

## usage
# bash run_pipe.sh <path_to_stlfr_read1> <path_to_stlfr_read2> <number_of_threads> <memory_limit_for_spades> <path_to_stLFR_Pipe_folder> <output_dir>

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
memory=$4
case $5 in
  /*) script_dir=$5;;
  *) script_dir=$PWD/$5;;
esac
case $6 in
  /*) out_dir=$6;;
  *) out_dir=$PWD/$6;;
esac

# step 0 enter output_dir
if [ ! -d "$out_dir" ]
then
    mkdir $out_dir
fi
rm -rf $out_dir/*
cd $out_dir

# step 1 stLFR_read_demux
perl $script_dir/stLFR_read_demux/scripts/split_barcode_PEXXX_42_reads.1.pl $script_dir/stLFR_read_demux/scripts/barcode.list $script_dir/stLFR_read_demux/scripts/barcode_RC.list $read1 $read2 100 $out_dir/split_read
perl $script_dir/stLFR_read_demux/scripts/split_barcode_PEXXX_42_reads.2.pl $script_dir/stLFR_read_demux/scripts/barcode.list $script_dir/stLFR_read_demux/scripts/barcode_RC.list $read1 $read2 100 $out_dir/split_read

# step 2 transform barcode
$script_dir/cpp_tools/parse_stlfr -1 $out_dir/split_read.1.fq.gz -2 $out_dir/split_read.2.fq.gz -l -b $script_dir/stLFR_read_demux/scripts/barcode.list -o $out_dir/split_read_parsed

# step 3 metaspades
metaspades.py --12 $out_dir/split_read_parsed_interleaved.fq -m $memory -t $thread -o $out_dir/metaspades --disable-gzip-output

# step 4 athena-meta
cp -r $script_dir/athena ./
cd athena
bash athena.sh $thread
