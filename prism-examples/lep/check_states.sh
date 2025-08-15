#!/bin/bash

propertie='P>0.5 [ F "leader_elected" ]'

for dir in */; do
    if [ -d "$dir" ]; then
    	#make prism model
    	echo "Building PRISM model"
    	
		prism $dir/lep.pm -dtmc -exportlabels /tmp/lep.lab -exporttrans /tmp/lep.tra > "/tmp/lep/$dir/prism-model-output"


		# PRISM standard
		echo "PRISM standard for $dir"
		echo -n "PRISM,standard" >> "/tmp/lep/$dir/time.csv"
		prism -explicit -bisim -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc | grep "Minimisation:"

		cd ../../prism-extension/prism4.8.1/prism/bin/
		 # PRISM Buchholz        
                echo "PRISM Buchholz for $dir"
                echo -n "PRISM,Buchholz" >> "/tmp/lep/$dir/time.csv"
                ./prism -algo explicit.Buchholz -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie"-dtmc | grep "Minimisation:"
		
		# PRISM DerisaviRedBlack	
		echo "PRISM DerisaviRedBlack for $dir"
		echo -n "PRISM,DerisaviRedBlack" >> "/tmp/lep/$dir/time.csv"
		./prism -algo explicit.DerisaviRedBlack -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc | grep "Minimisation:"

		
		# PRISM DerisaviSplayTree	
		echo "PRISM DerisaviSplayTree for $dir"
		echo -n "PRISM,DerisaviSplayTree" >> "/tmp/lep/$dir/time.csv"
		./prism -algo explicit.DerisaviSplayTree -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc | grep "Minimisation:"
		

		# PRISM Valmari	
		echo "PRISM Valmari for $dir"
		echo -n "PRISM,Valmari" >> "/tmp/lep/$dir/time.csv"
		./prism -algo explicit.Valmari -explicitbuild -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab -pf "$propertie" -dtmc | grep "Minimisation:"

		cd /eecs/research/discoveri/summer24/prism-examples/lep
		pwd
    fi
done
