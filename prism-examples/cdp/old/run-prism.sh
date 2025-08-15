if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <N> <R>"
    exit 1
fi

N=$1
R=$2
DIR="${N}-${R}"

prism cdp.pm -const CrowdSize=$N,TotalRuns=$R -exportlabels "$DIR/cdp.lab" -exporttrans "$DIR/cdp.tra"
prism -explicit -bisim -importtrans "$DIR/cdp.tra" -importlabels "$DIR/cdp.lab" cdp.pctl -dtmc 

