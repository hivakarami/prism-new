#!/bin/bash

propertie='P>0.5 [ true U<=5000 "leader_elected" ]'

for dir in */; do
    if [ -d "$dir" ]; then
    	#make prism model
    	echo "Building PRISM model"
    	
		prism $dir/lep.pm -dtmc -exportlabels /tmp/lep2.lab -exporttrans /tmp/lep2.tra > "/tmp/lep2/$dir/prism-model-output"

		rm "/tmp/lep2/$dir/time.csv"

		cd ../../prism-extension/prism4.8.1/prism/bin/

		# PRISM Buchholz	
		echo "PRISM Buchholz for $dir"
		echo -n "PRISM,Buchholz" >> "/tmp/lep2/$dir/time.csv"
		./prism -algo explicit.Buchholz -explicitbuild -importtrans /tmp/lep2.tra -importlabels /tmp/lep2.lab -pf "$propertie" -dtmc
		for i in $(seq 1 20); do
			(time -p ./prism -algo explicit.Buchholz -explicitbuild -importtrans /tmp/lep2.tra -importlabels /tmp/lep2.lab -pf "$propertie" -dtmc) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/lep2/$dir/time.csv"
		done
		echo "" >> "/tmp/lep2/$dir/time.csv"
		
		cd /eecs/research/discoveri/summer24/prism-examples/lep
		
    fi
done


