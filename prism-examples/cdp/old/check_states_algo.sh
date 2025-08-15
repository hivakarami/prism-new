#!/bin/bash

propertie='P<0.5 [ true U<=1000 "observe" ]'

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
	
	#make prism model
	echo "Building PRISM model"
	prism cdp.pm -const CrowdSize=$N,TotalRuns=$R -exportlabels /tmp/cdp.lab -exporttrans /tmp/cdp.tra  > "/tmp/cdp/$DIR/prism-model-output"
	
	# PRISM standard
	echo "PRISM standard for $DIR"
	prism -javamaxmem 3000m -explicit -bisim -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab cdp.pctl -dtmc  | grep "Minimisation:"
	cd ../../prism-extension/prism4.8.1/prism/bin/
	
	# PRISM Buchholz  
	echo "PRISM Buchholz for $DIR"
	./prism -algo explicit.Buchholz -explicitbuild -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf "$propertie" -dtmc | grep "Minimisation:"

	# PRISM DerisaviRedBlack	
	echo "PRISM DerisaviRedBlack for $DIR"
	
	./prism -algo explicit.DerisaviRedBlack -explicitbuild -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf "$propertie" -dtmc | grep "Minimisation:"

		
	# PRISM DerisaviSplayTree	
	echo "PRISM DerisaviSplayTree for $DIR"
	./prism -algo explicit.DerisaviSplayTree -explicitbuild -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf "$propertie" -dtmc | grep "Minimisation:"
	

	# PRISM Valmari	
	echo "PRISM Valmari for $DIR"
	./prism -algo explicit.Valmari -explicitbuild -importtrans /tmp/cdp.tra -importlabels /tmp/cdp.lab -pf "$propertie" -dtmc | grep "Minimisation:"
	
	cd /eecs/research/discoveri/summer24/prism-examples/cdp
done



