BEGIN {
       sends=0;
       recvs=0;
       routing_packets=0;
       droppedPackets=0;
       highest_packet_id =0;
       sum=0;
       recvnum=0;
     }
  {
  time = $2;
  packet_id = $6;
  event =$1;
  # CALCULATE PACKET DELIVERY FRACTION
  if (( $1 == "s") &&  ( $7 == "cbr" ) && ( $4=="AGT" )) {  sends++; }
  if (( $1 == "r") &&  ( $7 == "cbr" ) && ( $4=="AGT" ))   {  recvs++; }
  # CALCULATE DELAY
  if ( start_time[packet_id] == 0 )  start_time[packet_id] = time;
  if (( $1 == "r") &&  ( $7 == "cbr" ) && ( $4=="AGT" )) {  end_time[packet_id] = time;  }
       else {  end_time[packet_id] = -1;  }
  # CALCULATE TOTAL AODV OVERHEAD
  if (($1 == "s" || $1 == "f" || $1="r") && $4 == "RTR" && ($7 =="AODV" ||$7 =="AOMDV")) routing_packets++;
  # DROPPED AODV PACKETS
  if (event == "D") droppedPackets++;
  }
  END {
  for ( i in end_time )
  {
  start = start_time[i];
  end = end_time[i];
  packet_duration = end - start;
  if ( packet_duration > 0 )
  {    sum += packet_duration;
       recvnum++;
  }
  }
     delay=sum/recvnum;
     NRL = routing_packets/recvs;  #normalized routing load
     PDF = (recvs/sends)*100;  #packet delivery ratio[fraction]
     printf("Send Packets = %.2f\n",sends);
     printf("Received Packets = %.2f\n",recvs);
     printf("Routing Packets = %.2f\n",routing_packets++);
     printf("Packet Delivery Function = %.2f\n",PDF);
     printf("Normalised Routing Load = %.2f\n",NRL);
     printf("Average end to end delay(ms)= %.2f\n",delay*1000);
     print("No. of dropped packets = ",droppedPackets);

}

