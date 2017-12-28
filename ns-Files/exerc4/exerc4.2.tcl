# ==================================================================#
# 		         General setup			 	    #
# ==================================================================#

# Create simulator
set ns    [new Simulator]

# Create the "general operations director"
# Set the output files for data.
set f0 [open sink0.tr w]
set f1 [open sink1.tr w]
set f2 [open sink2.tr w]
set f3 [open sink3.tr w]
set f4 [open sink4.tr w]

# Enable the nam trace
$ns trace-all [open hw3.1.tr w]
$ns namtrace-all [open hw3.1.nam w]
# Create the following procedure which launches nam
proc finish {} {
	global ns f0 f1 f2 f3 f4
	$ns flush-trace
	puts "running nam..."
	exec nam -a hw3.1.nam &
        #Close the output files
        close $f0
        close $f1
        close $f2
        close $f3
        close $f4

	exec xgraph -x Time(s) -y Rate(Mbps) -geometry 800x400 sink0.tr sink1.tr sink2.tr sink3.tr sink4.tr &
	exit 0
}
proc record {} {
        global sink0 sink1 sink2 sink3 sink4 f0 f1 f2 f3 f4
        #Get an instance of the simulator
        set ns [Simulator instance]
        #Set the time after which the procedure should be called again
        set time 0.5
        #How many bytes have been received by the traffic sinks?
        set bw0 [$sink0 set bytes_]
        set bw1 [$sink1 set bytes_]
        set bw2 [$sink2 set bytes_]
        set bw3 [$sink3 set bytes_]
        set bw4 [$sink4 set bytes_]

        #Get the current time
        set now [$ns now]
        #Calculate the bandwidth (in MBit/s) and write it to the files
        puts $f0 "$now [expr $bw0/$time*8/1000000]"
        puts $f1 "$now [expr $bw1/$time*8/1000000]"
        puts $f2 "$now [expr $bw2/$time*8/1000000]"
        puts $f3 "$now [expr $bw3/$time*8/1000000]"
        puts $f4 "$now [expr $bw4/$time*8/1000000]"

        #Reset the bytes_ values on the traffic sinks
        $sink0 set bytes_ 0
        $sink1 set bytes_ 0
        $sink2 set bytes_ 0
        $sink3 set bytes_ 0
        $sink4 set bytes_ 0
        
	#Re-schedule the procedure
        $ns at [expr $now+$time] "record"
}

# ==================================================================#
# 		Nodes configuration and setup			    #
# ==================================================================#

# Creates 15 nodes n0, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14
set n0 [$ns node]	;# TCP source 0
set n1 [$ns node]	;# TCP source 1
set n2 [$ns node]	;# TCP source 2
set n3 [$ns node]	;# TCP source 3
set n4 [$ns node]	;# TCP source 4
set n5 [$ns node]	;# Router 0
set n6 [$ns node]	;# Router 1
set n7 [$ns node]	;# Router 2
set n8 [$ns node]	;# Router 3
set n9 [$ns node]	;# Router 4
set n10 [$ns node]	;# sink 0
set n11 [$ns node]	;# sink 1
set n12 [$ns node]	;# sink 2
set n13 [$ns node]	;# sink 3
set n14 [$ns node]	;# sink 4
set n15 [$ns node]	;# All TCP sinks

# Create the following topology, where
# TCP sources are connected to routers 
# by a duplex-link with capacity 5Mbps
# propagation delay 20ms, dropping discipline “DropTail”.
$ns duplex-link $n0 $n5 5Mb 20ms DropTail
$ns duplex-link $n1 $n6 5Mb 20ms DropTail
$ns duplex-link $n2 $n7 5Mb 20ms DropTail
$ns duplex-link $n3 $n8 5Mb 20ms DropTail
$ns duplex-link $n4 $n9 5Mb 20ms DropTail

# Routers are connected by a duplex-link with
# capacity 2.5 Mbps, propagation delay 50ms, and
# dropping discipline “DropTail”.
$ns duplex-link $n5 $n6 0.5Mb 100ms DropTail
$ns duplex-link $n6 $n7 0.5Mb 100ms DropTail
$ns duplex-link $n7 $n8 0.5Mb 100ms DropTail
$ns duplex-link $n8 $n9 0.5Mb 100ms DropTail
$ns duplex-link $n9 $n15 0.5Mb 100ms DropTail
# n2-> n3 and n5 connected by a duplex-link with capacity 25Mbps,
# propagation delay 10ms, dropping discipline “DropTail”.
$ns duplex-link $n15 $n10 0.5Mb 100ms DropTail
$ns duplex-link $n15 $n11 0.5Mb 100ms DropTail
$ns duplex-link $n15 $n12 0.5Mb 100ms DropTail
$ns duplex-link $n15 $n13 0.5Mb 100ms DropTail
$ns duplex-link $n15 $n14 0.5Mb 100ms DropTail

# Instruct nam how to display the nodes
$ns duplex-link-op $n0 $n5 orient up
$ns duplex-link-op $n1 $n6 orient up
$ns duplex-link-op $n2 $n7 orient up
$ns duplex-link-op $n3 $n8 orient up
$ns duplex-link-op $n4 $n9 orient up
$ns duplex-link-op $n5 $n6 orient right
$ns duplex-link-op $n6 $n7 orient right
$ns duplex-link-op $n7 $n8 orient right
$ns duplex-link-op $n8 $n9 orient right
$ns duplex-link-op $n9 $n15 orient right
$ns duplex-link-op $n15 $n10 orient up
$ns duplex-link-op $n15 $n11 orient right-up
$ns duplex-link-op $n15 $n12 orient right
$ns duplex-link-op $n15 $n13 orient right-down
$ns duplex-link-op $n15 $n14 orient down

# ==================================================================#
# 			Agents					    #
# ==================================================================#

# Establish a TCP connection between TCP source and sink
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n10 $sink0
$ns connect $tcp0 $sink0

set tcp1 [new Agent/TCP]
$ns attach-agent $n1 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n11 $sink1
$ns connect $tcp1 $sink1

set tcp2 [new Agent/TCP]
$ns attach-agent $n2 $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $n12 $sink2
$ns connect $tcp2 $sink2

set tcp3 [new Agent/TCP]
$ns attach-agent $n3 $tcp3
set sink3 [new Agent/TCPSink]
$ns attach-agent $n13 $sink3
$ns connect $tcp3 $sink3

set tcp4 [new Agent/TCP]
$ns attach-agent $n4 $tcp4
set sink4 [new Agent/TCPSink]
$ns attach-agent $n14 $sink4
$ns connect $tcp4 $sink4

# Create an FTP transfer (using the TCP agent)
# between n0 and n3

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3
set ftp4 [new Application/FTP]
$ftp4 attach-agent $tcp4

#$ns attach-agent $sink0 $n15
#$ns attach-agent $sink1 $n15
#$ns attach-agent $sink2 $n15
#$ns connect $sink3 $n15
#$ns connect $sink4 $n15

$ns at 0.0 "record"
# Start the data transfer:
$ns at 0.1 "$ftp0 start"
$ns at 0.1 "$ftp1 start"
$ns at 0.1 "$ftp2 start"
$ns at 0.1 "$ftp3 start"
$ns at 0.1 "$ftp4 start"

# Stop the data transfer:
$ns at 10.0 "$ftp0 stop"
$ns at 10.0 "$ftp1 stop"
$ns at 10.0 "$ftp2 stop"
$ns at 10.0 "$ftp3 stop"
$ns at 10.0 "$ftp4 stop"

# Launch the animation
$ns at 10.1 "finish"
$ns run




