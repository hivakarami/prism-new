#!/bin/bash

propertie='P>0.5 [ true U<=5000 "leader_elected" ]'

# Number of iterations
num_iterations=1

# Define the combinations of N and R
combinations=(
	"4-2"
	"4-4"
	"4-8"
	"5-2"
	"5-4"
	"5-6"
	"5-8"
    "4-16"
)


# Loop through each combination
for combo in "${combinations[@]}"; do
    DIR="$combo"
    
	#make prism model
	echo "Building PRISM model"
	prism $DIR/lep.pm -dtmc -exportlabels /tmp/lep.lab -exporttrans /tmp/lep.tra > "/tmp/lep/$DIR/prism-model-output"

	cd ../../prism-extension/prism4.8.1/prism/bin/
	

	# PRISM Buchholz  
	rm "/tmp/lep/$DIR/time_Buchholz.csv"
	echo "PRISM Buchholz for $DIR"
	echo -n "PRISM,Buchholz" >> "/tmp/lep/$DIR/time_Buchholz.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -algo explicit.Buchholz -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/lep/$DIR/time_Buchholz.csv"
	done
	echo "" >> "/tmp/lep/$DIR/time_Buchholz.csv"	
	
	./prism -algo explicit.Buchholz -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc | grep "Minimisation:" # test
	
	# PRISM Valmari  
	rm "/tmp/lep/$DIR/time_Valmari.csv"
	echo "PRISM Valmari for $DIR"
	echo -n "PRISM,Valmari" >> "/tmp/lep/$DIR/time_Valmari.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -algo explicit.Valmari -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/lep/$DIR/time_Valmari.csv"
	done
	echo "" >> "/tmp/lep/$DIR/time_Valmari.csv"	

	./prism -algo explicit.Valmari -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc | grep "Minimisation:" # test

	# PRISM DerisaviSplayTree  
	rm "/tmp/lep/$DIR/time_DerisaviSplayTree.csv"
	echo "PRISM DerisaviSplayTree for $DIR"
	echo -n "PRISM,DerisaviSplayTree" >> "/tmp/lep/$DIR/time_DerisaviSplayTree.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -algo explicit.DerisaviSplayTree -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/lep/$DIR/time_DerisaviSplayTree.csv"
	done
	echo "" >> "/tmp/lep/$DIR/time_DerisaviSplayTree.csv"	

	./prism -algo explicit.DerisaviSplayTree -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc | grep "Minimisation:" # test

	
	# PRISM DerisaviRedBlack  
	rm "/tmp/lep/$DIR/time_DerisaviRedBlack.csv"
	echo "PRISM DerisaviRedBlack for $DIR"
	echo -n "PRISM,DerisaviRedBlack" >> "/tmp/lep/$DIR/time_DerisaviRedBlack.csv"
	for i in $(seq 1 $num_iterations); do
		(time -p ./prism -algo explicit.DerisaviRedBlack -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/lep/$DIR/time_DerisaviRedBlack.csv"
	done
	echo "" >> "/tmp/lep/$DIR/time_DerisaviRedBlack.csv"	

	./prism -algo explicit.DerisaviRedBlack -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc | grep "Minimisation:" # test

	
	cd /eecs/research/discoveri/summer24/prism-examples/lep
done
