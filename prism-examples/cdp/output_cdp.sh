#!/bin/bash
for dir in */; do
	if [ -d "$dir" ]; then
		echo "$dir"
		cat "/tmp/cdp/$dir/time.csv"
		#echo ""
		#cat "/tmp/cdp/$dir/time_Standard.csv"
		#cat "/tmp/cdp/$dir/time_Buchholz.csv"
		#cat "/tmp/cdp/$dir/time_DerisaviSplayTree.csv"
		#cat "/tmp/cdp/$dir/time_DerisaviRedBlack.csv"
		#cat "/tmp/cdp/$dir/time_Valmari.csv"	
		echo ""
	fi
done
