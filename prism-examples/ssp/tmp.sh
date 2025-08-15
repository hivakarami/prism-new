#!/bin/bash

for dir in */; do
    if [ -d "$dir" ]; then
    	#make prism model
    	echo "Building PRISM model"

		#make MRMC model
		echo "Building MRMC model"

		prism $dir/ssp.pm -dtmc -exportmrmc -exportlabels /tmp/ssp.lab -exporttrans /tmp/ssp.tra > "/tmp/ssp/$dir/mrmc-model-output"

		echo "" >> "/tmp/ssp/$dir/time.csv"

		# MRMC standard
		echo "MRMC standard for $dir"
		echo -n "MRMC,standard" >> "/tmp/ssp/$dir/time.csv"

		for i in $(seq 1 50); do
			(time -p mrmc dtmc -ilump /tmp/ssp.tra /tmp/ssp.lab < input) 2>&1 | awk '/^user/ {printf ","$2}' >> "/tmp/ssp/$dir/time.csv"
		done

		echo "" >> "/tmp/ssp/$dir/time.csv"
    fi
done

