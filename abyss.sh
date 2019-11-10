export i
for i in {48..50}; do
	    mkdir k$i
	        abyss-pe -C k$i k=$i name=aliivibrio in='/Users/anamulbahar/Work/aliivibrio/read1.fastq /Users/anamulbahar/Work/aliivibrio/read2.fastq'
	done
	abyss-fac k*/aliivibrio_contigs.fa
	