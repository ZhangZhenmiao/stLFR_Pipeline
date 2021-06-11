# stLFR_Pipe

## Requirements
* [htslib](https://github.com/samtools/htslib)
* [seqtk](https://github.com/lh3/seqtk)
* [megahit](https://github.com/voutcn/megahit)
* [bwa](https://github.com/lh3/bwa)
* [samtools](https://github.com/samtools/samtools) (tested v1.9)
* [athena-meta](https://github.com/abishara/athena_meta)
* [gcc](https://gcc.gnu.org/) (C++11)

## Install
`git clone https://github.com/ZhangZhenmiao/stLFR_Pipe.git && cd stLFR_Pipe && make && chmod +x *.sh *.py`

You need add the install folder to the `$PATH` variable.

## Usage
`run_pipe.sh <path_to_stlfr_read1> <path_to_stlfr_read2> <number_of_threads> <path_to_"stLFR_Pipe"_folder> <output_folder> <barcode_type, i.e., 30/42/54>`

test_run/test.sh is an example.
