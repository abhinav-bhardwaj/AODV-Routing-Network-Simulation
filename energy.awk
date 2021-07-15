BEGIN {
        initialenergy = 1000
        n=11
	maxenergy=0
	totalenergy=0
}
{
    # Trace line format: energy
        event = $1
        if (event == "r" || event == "D" || event == "s"|| event == "f") {
        	node_id = $3
        	energy=$14
        }
        if (event=="N"){
        	node_id = $5
        	energy=$7
        }
    # Store remaining energy
    finalenergy[node_id]=energy
}
END {
    # Compute consumed energy for each node
    for (i=0;i<n;i=i+1) {
        consumenergy[i]=initialenergy-finalenergy[i]
        totalenergy += consumenergy[i]
        if(maxenergy<consumenergy[i]){
       		 maxenergy=consumenergy[i]
        }
    }
    #compute average energy
    averagenergy=totalenergy/n
    #output
    for (i=0; i<n; i++) {
        print("node",i, consumenergy[i])
    }
        print("average",averagenergy)
        print("total energy",totalenergy)
	print("max energy consumed",maxenergy)
}
