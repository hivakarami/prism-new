#!/bin/bash

for dir in */; do
    if [ -d "$dir" ]; then
    	#make prism model
    	echo "Building PRISM model"

		prism $dir/ssp.pm -dtmc -exportlabels /tmp/ssp.lab -exporttrans /tmp/ssp.tra > "/tmp/ssp/$dir/prism-model-output"

		rm "/tmp/ssp/$dir/time.csv"

		# PRISM without
		echo "PRISM without for $dir"
		echo -n "PRISM,without" >> "/tmp/ssp/$dir/time.csv"


		prism -javamaxmem 99999m -explicit -importtrans /tmp/ssp.tra -importlabels /tmp/ssp.lab ssp.pctl -dtmc


		echo "" >> "/tmp/ssp/$dir/time.csv"

		# PRISM standard
		echo "PRISM standard for $dir"
		echo -n "PRISM,standard" >> "/tmp/ssp/$dir/time.csv"

		prism -javamaxmem 99999m -explicit -bisim -importtrans /tmp/ssp.tra -importlabels /tmp/ssp.lab ssp.pctl -dtmc

		#make MRMC model
		echo "Building MRMC model"

		prism $dir/ssp.pm -dtmc -exportmrmc -exportlabels /tmp/ssp.lab -exporttrans /tmp/ssp.tra > "/tmp/ssp/$dir/mrmc-model-output"

		echo "" >> "/tmp/ssp/$dir/time.csv"

		# MRMC without
		echo "MRMC without for $dir"
		echo -n "MRMC,without" >> "/tmp/ssp/$dir/time.csv"

	
		mrmc dtmc /tmp/ssp.tra /tmp/ssp.lab < input
	

		echo "" >> "/tmp/ssp/$dir/time.csv"

		# MRMC standard
		echo "MRMC standard for $dir"
		echo -n "MRMC,standard" >> "/tmp/ssp/$dir/time.csv"

		mrmc dtmc -ilump /tmp/ssp.tra /tmp/ssp.lab < input
	

		echo "" >> "/tmp/ssp/$dir/time.csv"
    fi
done

