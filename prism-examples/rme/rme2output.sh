#!/bin/bash
for dir in */; do
	if [ -d "$dir" ]; then
		echo "$dir"
		cat "/tmp/rme2/$dir/time_Buchholz.csv"
		#cat "/tmp/rme/$dir/time_Valmari.csv"
		#cat "/tmp/rme/$dir/time_DerisaviSplayTree.csv"
		#cat "/tmp/rme/$dir/time_DerisaviRedBlack.csv"
		echo ""
	fi
done
