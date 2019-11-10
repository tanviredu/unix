#!/bin/bash
current_path=`pwd`
export gatk4='/home/masum/Documents/ZAMS/v1/gatk-4.1.1.0/gatk'
export samtools='/usr/bin/samtools'
export bwa='/usr/bin/bwa'
export fastq1=$1
export fastq2=$2
export ref=$3
export threads=$4
export sample=$5
export group=1

mkdir ${current_path}/"index"

#Extract reference path
foo=$ref
for (( i=0; i<${#foo}; i++ )); do char="${foo:$i:1}"
if [ "$char" == "/" ]; then pos=$i; fi
if [ "$char" == "." ]; then dpos=$i; fi
done

interval=$((dpos-pos-1))
refName=${foo:pos+1:$interval}
dir=${foo:0:pos}

echo `${samtools} faidx $ref`

if [ -z "$dir" ]; then 
  ${gatk4} CreateSequenceDictionary -R $ref -O $refName.dict
else
  ${gatk4} CreateSequenceDictionary -R $ref -O $dir/$refName.dict
fi

bigRef="bwtsw"
smallRef="is"
threshold=2000000000
refsize=$(wc -c < $ref)

if [ $refsize -ge $threshold ]; then
    echo `${bwa} index -p index/ref -a $bigRef $ref`
else
    echo `${bwa} index -p index/ref -a $smallRef $ref`
fi

echo `${bwa} mem -t $threads -M -R '@RG\tID:$group\tLB:$group\tPL:ILLUMINA\tSM:$sample' index/ref $fastq1 $fastq2 | samtools view -b -S -o $sample.bam`
echo `${gatk4} --java-options "-Xmx1G" SortSam -I $sample.bam -O $sample.sorted.bam -SO coordinate --CREATE_INDEX true`
echo `${gatk4} --java-options "-Xmx1G" MarkDuplicates -I $sample.sorted.bam -O $sample.dedup.bam -M $sample.metrics --REMOVE_DUPLICATES true --CREATE_INDEX true`
echo `rm -rf $sample.bam $sample.sorted.bam $sample.sorted.bai`
echo `${gatk4} --java-options "-Xmx1G" HaplotypeCaller -R $ref -I $sample.dedup.bam -O gatk4.raw.vcf`
