#!/bin/bash
for dir in */; do
	if [ -d "$dir" ]; then
		echo "$dir"
		#cat "/tmp/lep/$dir/time.csv"
		cat "/tmp/lep/$dir/time_Buchholz.csv"
		cat "/tmp/lep/$dir/time_DerisaviSplayTree.csv"
		cat "/tmp/lep/$dir/time_DerisaviRedBlack.csv"
		cat "/tmp/lep/$dir/time_Valmari.csv"
		echo ""
	fi
done
