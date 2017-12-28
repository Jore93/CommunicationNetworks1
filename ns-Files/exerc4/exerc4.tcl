# ==================================================================#
# 		         General setup			 	    #
# ==================================================================#

# Create simulator
set ns    [new Simulator]

# Create the "general operations director"
# Set the output files for data.
set f0 [open outTCP.tr w]
set f1 [open outUDP.tr w]

# Enable the nam trace
$ns trace-all [open hw3.tr w]
$ns namtrace-all [open hw3.nam w]
# Create the following procedure which launches nam
proc finish {} {
	global ns f0 f1
	$ns flush-trace
	puts "running nam..."
	exec nam -a hw3.nam &
        #Close the output files
        close $f0
        close $f1

	exec xgraph -x Time(s) -y Rate(Mbps) -geometry 800x400 outTCP.tr outUDP.tr &
	exit 0
}
proc record {} {
        global sink_tcp sink_udp f0 f1
        #Get an instance of the simulator
        set ns [Simulator instance]
        #Set the time after which the procedure should be called again
        set time 0.5
        #How many bytes have been received by the traffic sinks?
        set bw0 [$sink_tcp set bytes_]
        set bw1 [$sink_udp set bytes_]
        #Get the current time
        set now [$ns now]
        #Calculate the bandwidth (in MBit/s) and write it to the files
        puts $f0 "$now [expr $bw0/$time*8/1000000]"
        puts $f1 "$now [expr $bw1/$time*8/1000000]"
        #Reset the bytes_ values on the traffic sinks
        $sink_tcp set bytes_ 0
        $sink_udp set bytes_ 0
        #Re-schedule the procedure
        $ns at [expr $now+$time] "record"
}

# ==================================================================#
# 		Nodes configuration and setup			    #
# ==================================================================#

# Creates six nodes n0, n1, n2, n3, n4, n5
set n0 [$ns node]	;# TCP source
set n1 [$ns node]	;# Router 1
set n2 [$ns node]	;# Router 2
set n3 [$ns node]	;# TCP sink
set n4 [$ns node]	;# UDP source
set n5 [$ns node]	;# UDP sink

# Create the following topology, where
# n0 and n4 -> n1 are connected by a duplex-link with
# capacity 5Mbps, propagation delay 20ms, dropping
# discipline “DropTail”.
$ns duplex-link $n0 $n1 25Mb 10ms DropTail
$ns duplex-link $n4 $n1 25Mb 10ms DropTail
# n1 and n2 are connected by a duplex-link with
# capacity 2.5 Mbps, propagation delay 50ms, and
# dropping discipline “DropTail”.
$ns duplex-link $n1 $n2 2.5Mb 50ms DropTail
# n2-> n3 and n5 connected by a duplex-link with capacity 25Mbps,
# propagation delay 10ms, dropping discipline “DropTail”.
$ns duplex-link $n2 $n3 25Mb 10ms DropTail
$ns duplex-link $n2 $n5 25Mb 10ms DropTail
# Create a bottleneck between n1 and n2, with a maximum queue
# size of 25 packets
$ns queue-limit $n1 $n2 25
# Instruct nam how to display the nodes
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient right-up
$ns duplex-link-op $n4 $n1 orient right-up
$ns duplex-link-op $n2 $n5 orient right
$ns duplex-link-op $n1 $n2 queuePos 2.5

# ==================================================================#
# 			Agents					    #
# ==================================================================#

# Establish a TCP connection between n0 and n3
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
set sink_tcp [new Agent/TCPSink]
$ns attach-agent $n3 $sink_tcp
$ns connect $tcp $sink_tcp
# Create an FTP transfer (using the TCP agent)
# between n0 and n3
set ftp [new Application/FTP]
$ftp attach-agent $tcp
#Establish a UDP/CBR connection between n4 and n5
set udp [new Agent/UDP]
$ns attach-agent $n4 $udp
set sink_udp [new Agent/LossMonitor]
$ns attach-agent $n5 $sink_udp
$ns connect $udp $sink_udp
# Create an CBR transfer (using the UDP agent)
# between n0 and n3
set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 5000
$cbr set rate_ 5Mb
$cbr attach-agent $udp

$ns at 0.0 "record"
# Start the data transfer:
$ns at 0.1 "$ftp start"
$ns at 0.1 "$cbr start"
# Stop the data transfer:
$ns at 5.0 "$ftp stop"
$ns at 5.0 "$cbr stop"
# Launch the animation
$ns at 5.1 "finish"
$ns run




