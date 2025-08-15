#!/bin/bash
for dir in */; do
    if [ -d "$dir" ]; then
    	#make prism model
    	echo "Building PRISM model"

		prism $dir/rme.pm rme.pctl -dtmc -exportlabels /tmp/rme.lab -exporttrans /tmp/rme.tra > "/tmp/rme/$dir/prism-model-output"

		# PRISM standard
		echo "PRISM standard for $dir"
		output=$( { prism -javamaxmem 3000m -explicit -bisim -importtrans /tmp/rme.tra -importlabels /tmp/rme.lab rme.pctl -dtmc; } )
		Minimisation=$(echo "$output" | grep "Minimisation:")
		echo "Minimisation : $Minimisation"


		prism $dir/rme.pm rme.pctl -dtmc -exportmrmc -exportlabels /tmp/rme.lab -exporttrans /tmp/rme.tra > "/tmp/rme/$dir/mrmc-model-output"

		# MRMC standard
		echo "MRMC standard for $dir"
		output=$( { mrmc -ilump dtmc /tmp/rme.tra /tmp/rme.lab < input; } )
		Minimisation=$(echo "$output" | grep "Lumping:")
		echo "Minimisation : $Minimisation"

		echo ""

    fi
done
