export i
for i in {48..50}; do
        /miniconda/bin/SOAPdenovo-63mer all -s /Users/anamulbahar/Work/aliivibrio/soapdenovo.config -o aliivibrio_$i -K $i -R 1>ass.log 2>ass.err
	done
