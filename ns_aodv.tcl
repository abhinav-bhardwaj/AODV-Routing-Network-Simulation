set val(chan) Channel/WirelessChannel;
set val(prop) Propagation/TwoRayGround;
set val(netif) Phy/WirelessPhy;
set val(mac) Mac/802_11;
set val(ifq) Queue/DropTail/PriQueue;
set val(ll) LL;
set val(ant) Antenna/OmniAntenna;
set val(ifqlen) 50;
set val(rp) AODV;
set val(nn) 11;
set val(x) 500;
set val(y) 400;
set val(stop) 3;

set val(energymodel) EnergyModel;
set val(initialenergy) 1000;

set ns [new Simulator]

set tf [open ns_aodv.tr w]
$ns trace-all $tf

set nf [open ns_aodv.nam w]
$ns namtrace-all-wireless $nf $val(x) $val(y)

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

set chan_1_ [new $val(chan)]

$ns node-config -adhocRouting $val(rp) \
	-llType $val(ll) \
	-macType $val(mac) \
	-ifqType $val(ifq) \
	-ifqLen $val(ifqlen) \
	-antType $val(ant) \
	-propType $val(prop) \
	-phyType $val(netif) \
	-channel $chan_1_ \
	-topoInstance $topo \
	-agentTrace ON \
	-routerTrace ON \
	-macTrace OFF \
	-movementTrace ON \
	-energyModel $val(energymodel) \
	-initialEnergy $val(initialenergy) \
	-rxPower 0.4 \
	-txPower 1.0 \
	-idlePower 0.6 \
	-sleepPower 0.1 \
	-transitionPower 0.4 \
	-transitionTime 0.1


for {set i 0} {$i < $val(nn)} {incr i} {
	set node_($i) [$ns node]
	$node_($i) set X_ [ expr 10+round(rand()*480) ]
	$node_($i) set Y_ [ expr 10+round(rand()*380) ]
	$node_($i) set Z_ 0.0
}

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns at [ expr 15+round(rand()*60) ] "$node_($i) setdest [ expr 10+round(rand()*480) ] [expr 10+round(rand()*380) ] [expr 2+round(rand()*15) ]"
}

#$ns duplex-link $node_(5) $node_(2) 2Mb 10ms DropTail

set udp [new Agent/UDP]
$ns attach-agent $node_(5) $udp
set null [new Agent/Null]
$ns attach-agent $node_(2) $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set packetSize_ 512
$cbr set interval_ 0.1
$cbr set rate_ 1mb
$cbr set maxpkts_ 10000
$ns connect $udp $null
$ns at 0.6 "$cbr start"

for {set i 0} {$i < $val(nn)} {incr i} {
        $ns initial_node_pos $node_($i) 30
}

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns at $val(stop) "$node_($i) reset";
}

#$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at 3.1  "puts \"end simulation\"; $ns halt"

proc finish {} {
        global ns tf nf
        $ns flush-trace
        close $tf
        close $nf
        exec nam ns_aodv.nam &
        exit 0
}

puts "CBR packet size = [$cbr set packetSize_]"
puts "CBR interval = [$cbr set interval_]"

$ns run
