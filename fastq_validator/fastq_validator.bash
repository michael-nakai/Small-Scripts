#!/bin/bash

#All paths
fastq_path=~/SHR/Bill_Grant/Fastq/*.fastq.gz
fastQValidator=~/gitclones/fastQValidator/bin/
ValidatorOutputs=~/fastQValidator_outputs/

#Set this variable to what the output folder should be named
dir=Bill_Grant

#Main starts here
echo 'Starting...'

mkdir ${ValidatorOutputs}${dir}
cd $fastQValidator

for f in $fastq_path;
do
	xbase=${f##*/}
	xpref=${xbase%.*}
	xpref2=${xpref%.*}
	./fastQValidator --file $f --avgQual --noeof > "${ValidatorOutputs}${dir}/${xpref2}.txt"
done

echo 'Validator done... starting summarization'

touch "${ValidatorOutputs}${dir}/summary.txt"

for f in "${ValidatorOutputs}${dir}/*";
do
	end=$(tail -n 1 $f)
	a="${f}\t${end}"
	echo "$a" >> "${ValidatorOutputs}${dir}/summary.tsv"
done

echo 'Summarization done'

echo "${ValidatorOutputs}${dir}/summary.tsv" | ./fastq_validator.py