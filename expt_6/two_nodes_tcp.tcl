#Creating simulator object
set ns [new Simulator]

#Creating 2 nodes
set n0 [$ns node]
set n1 [$ns node]

#Opening the NAM trace file
set nf [open A1-stop-n-wait.nam w]
$ns namtrace-all $nf
set f [open A1-stop-n-wait.tr w]
$ns trace-all $f

# Defining the "finish" procedure
proc finish {} {
    global ns nf
    $ns flush-trace

    #Closing the NAM trace file
    close $nf
    puts "filtering..."

    #Execute NAM on the trace file
    exec nam A1-stop-n-wait.nam &
    exit 0
}

#Creating links between the nodes
$ns duplex-link $n0 $n1 0.2Mb 200ms DropTail

#Giving node positions:   
# this means n0 ---> n1 ie node 1 will be to the right of node 0
$ns duplex-link-op $n0 $n1 orient right

#Setting up tcp connection
set tcp [new Agent/TCP]
$tcp set window_ 1
$tcp set maxcwnd_ 1
$ns attach-agent $n0 $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n1 $sink
$ns connect $tcp $sink

#Setting up FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp

#Scheduling events
$ns at 0.1 "$ftp start"
$ns at 3.0 "$ns detach-agent $n0 $tcp ; $ns detach-agent $n1 $sink"

#Calling the finish procedure after 3.5seconds
$ns at 3.5 "finish"

#$ns at 0.0 "$ns trace-annotate \"Stop and Wait with normal operation\""
#$ns at 0.05 "$ns trace-annotate \"FTP starts at 0.1\""


#Running the simulation
$ns run