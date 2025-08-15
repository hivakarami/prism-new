#!/bin/bash

propertie='P<0.5 [ true U<=1000 "observe" ]'

combinations=(
	"15 4"
)

# Loop through each combination
for combo in "${combinations[@]}"; do
    read N R <<< "$combo"
    DIR="${N}-${R}"

	#make prism model
	echo "Building PRISM model"
	prism cdp.pm -const CrowdSize=$N,TotalRuns=$R -exportlabels /tmp/cdp.lab -exporttrans /tmp/cdp.tra  > "/tmp/cdp/$DIR/prism-model-output"

	cd ../../prism-extension/prism4.8.1/prism/bin/

	# PRISM Valmari	
	echo "PRISM Valmari for $DIR"
	echo -n "PRISM,Valmari" >> "/tmp/cdp/$DIR/time.csv"
		for i in $(seq 1 20); do
			(time -p ./prism -algo explicit.Valmari -explicitbuild -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp/$DIR/time.csv"
		done
	echo "" >> "/tmp/cdp/$DIR/time.csv"

	cd /eecs/research/discoveri/summer24/prism-examples/cdp
done



