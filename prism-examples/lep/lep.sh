#!/bin/bash

for dir in */; do
    if [ -d "$dir" ]; then
	echo "Create MRMC model for $dir"
	prism $dir/lep.pm lep.pctl -exportmrmc -exportlabels /tmp/lep.lab -exporttrans /tmp/lep.tra | grep -E "States|Transitions"

	echo "Reduce MRMC model"
	mrmc dtmc -ilump /tmp/lep.tra /tmp/lep.lab < input | grep "Lumping:"

	echo "Create Storm model for $dir"
	sed -i '1,2c dtmc' /tmp/lep.tra

	echo "Reduce Storm model"
	storm --explicit /tmp/lep.tra /tmp/lep.lab --prop "P>0.5 [ F<=15 \"leader_elected\" ]" --bisimulation
	
	echo "Create PRISM model for $dir"
	prism $dir/lep.pm lep.pctl -exportlabels /tmp/lep.lab -exporttrans /tmp/lep.tra > /dev/null

	echo "Reduce PRISM model"
	prism -explicit -bisim -importtrans /tmp/lep.tra -importlabels /tmp/lep.lab lep.pctl -dtmc | grep "Minimisation:"
    fi
done



