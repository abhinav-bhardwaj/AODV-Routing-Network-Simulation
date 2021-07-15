BEGIN {
       recvdSize = 0
       startTime = 2.0
       stopTime = 0
       sent=0
       received=0
       dropped=0
       forwarded=0
}
  {
    # Trace line format: new
    	event = $1
        time = $2
        node_id = $3
        pkt_id = $6
        pkt_size = $8
       	level = $4
  }
{
  # Store start time
  if ((level == "AGT" && event == "s") && pkt_size >= 512) {
    	sent++
	if (time < startTime) {
             startTime = time
             }
  }
  if (event == "D" && pkt_size >= 512) {
        dropped++
  }
  if (event == "f" && pkt_size >= 512) {
        forwarded++
  }

  # Update total received packets' size and store packets arrival time
  if (level == "AGT" && event == "r" && pkt_size >= 512) {
       if (time > stopTime) {
             stopTime = time
       }
       received++
       # Rip off the header
       hdr_size = pkt_size % 512
       pkt_size -= hdr_size
       # Store received packet's size
       recvdSize += pkt_size
  }
}
  END {
       printf("Average Throughput[kbps] = %.2f\t\t StartTime=%.2f\tStopTime=%.2f\n",(recvdSize/(stopTime-startTime))*(8/1000),startTime,stopTime)
       print("Sent - ",sent)
       print("Received - ",received)
       print("Dropped - ",dropped)
       print("Forwarded",forwarded)
}
