#!/bin/bash

propertie='P<0.5 [ true U<=1000 "observe" ]'

# Define the combinations of N and R
combinations=(
	"5 3"
	"5 4"
	"5 5"
	"5 6"
	"10 3"
	"10 4"
	"10 5"
	"10 6"
	"15 3"
	"15 4"
	"15 5"
	"15 6" 
)

# Loop through each combination
for combo in "${combinations[@]}"; do
    read N R <<< "$combo"
    DIR="${N}-${R}"

	rm "/tmp/cdp/$DIR/time_buchholz.csv"

	#make prism model
	echo "Building PRISM model"
	prism cdp.pm -const CrowdSize=$N,TotalRuns=$R -exportlabels /tmp/cdp.lab -exporttrans /tmp/cdp.tra  > "/tmp/cdp/$DIR/prism-model-output"

	cd ../../prism-extension/prism4.8.1/prism/bin/
	

	# PRISM Buchholz  
	echo "PRISM Buchholz for $DIR"
	./prism -algo explicit.Buchholz -explicitbuild -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf "$propertie" -dtmc | grep "Minimisation:" # test
	
	echo -n "PRISM,Buchholz" >> "/tmp/cdp/$DIR/time_buchholz.csv"
	for i in $(seq 1 1); do
		(time -p ./prism -algo explicit.Buchholz -explicitbuild -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/cdp/$DIR/time_buchholz.csv"
	done
	echo "" >> "/tmp/cdp/$DIR/time_buchholz.csv"	
	
	cd /eecs/research/discoveri/summer24/prism-examples/cdp
done


