#!/bin/bash

all='1-65535'
tcp_custom='1-1040,1050,1080,1099,1158,1344,1352,1433,1521,1720,1723,1883,1911,1962,2202,2375,2628,2947,3000,3031,3050,3260,3306,3310,3389,3500,3632,4369,5019,5040,5060,5432,5560,5631,5632,5666,5672,5850,5900,5920,5984,5985,6000,6001,6002,6003,6004,6005,6379,6666,7210,7634,7777,8000,8009,8080,8081,8091,8222,8332,8333,8400,8443,8834,9000,9084,9100,9160,9600,9999,10000,11211,12000,12345,13364,19150,27017,28784,30718,35871,37777,46824,49152,50000,50030,50060,50070,50075,50090,60010,60030'

TCP=$all

udp_leebaird='53,67,123,137,161,407,500,523,623,1434,1604,1900,2302,2362,3478,3671,5353,5683,6481,17185,31337,44818,47808'
udp_discover='53,67,123,137-139,161,523,1434,1604,5093'
udp_top50='7,53,67-69,80,111,123,135-139,161,162,445,500,514,518,520,593,626,631,996-999,1025-1027,1433,1434,1645,1646,1701,1812,1900,2048,2049,2222,3283,3456,4500,5060,5353,20031,32768,49152,49153,49154'
udp_top50_other='523,623,1604,2302,2362,3478,3671,6481,17185,31337,44818,47808'
udp_top100='7,9,17,19,49,53,67-69,80,88,111,120,123,135-139,158,161,162,177,427,443,445,497,500,514,515,518,520,593,623,626,631,996-999,1022,1023,1025-1030,1433,1434,1645,1646,1701,1718,1719,1812,1813,1900,2000,2048,2049,2222,2223,3283,3456,3703,4444,4500,5000,5060,5353,5632,9200,10000,17185,20031,30718,31337,32768,32769,32771,32815,33281,49152-49154,49156,49181,49182,49186,49188,49190-49194,49200,49201,49211,65024'
udp_top100_other='523,1604,2302,2362,3478,3671,6481,44818,47808'

UDP=$udp_top100,$udp_top100_other


if [ -z $1 ];then
  printf "\nSyntax: ./$0 <file of ips> <Option|-t (tcp) or -u (udp) or -a (tcp & udp)> <optional: file of tcp ports>\n\n"
else
  FILE=$1
  OPTION=$2
  PORTS=${3:-}

  if [[ -f $FILE ]]; then
    echo $FILE does not exist!
    return 1
  fi

  if [ $OPTION == '-t' ];then
    run_tcp $FILE $PORTS
  elif [ $OPTION == '-u' ];then
    run_udp $FILE
  elif [ $OPTION == '-a' ];then
    run_tcp $FILE $PORTS
    run_udp $FILE
  else
	  echo 'Dammit Bobby.'
  fi
fi

run_tcp() {
  FILE=$1
  PORTS=$2

  if [[ -n $PORTS ]]; then
    if [[ -f $PORTS ]]; then
      TCP=$(cat $PORTS | tr '\n' ',' | sed -e 's/,$//')
    else
      echo $PORTS does not exist!
      return 1
    fi
  fi

  echo "# nmap -v -Pn -sT -sV --version-intensity 9 -O --script=default --traceroute -T4 -p T:$TCP --initial-rtt-timeout=200ms --min-rtt-timeout=100ms --max-rtt-timeout=1000ms --defeat-rst-ratelimit --open --stats-every 15s -oA tcp -iL $FILE"
  sudo nmap -v -Pn -sT -sV --version-intensity 9 -O --script=default --traceroute -T4 -p T:$TCP --initial-rtt-timeout=200ms --min-rtt-timeout=100ms --max-rtt-timeout=1000ms --defeat-rst-ratelimit --open --stats-every 15s -oA tcp -iL $FILE | tee tcp.out
}

run_udp() {
  FILE=$1

  echo "# nmap -v -Pn -sU -sV --version-intensity 2 -O --script=default --traceroute -T4 -p U:$UDP --initial-rtt-timeout=200ms --min-rtt-timeout=100ms --max-rtt-timeout=1000ms --defeat-rst-ratelimit --open --stats-every 15s -oA udp -iL $FILE"
  sudo nmap -v -Pn -sU -sV --version-intensity 2 -O --script=default --traceroute -T4 -p U:$UDP --initial-rtt-timeout=200ms --min-rtt-timeout=100ms --max-rtt-timeout=1000ms --defeat-rst-ratelimit --open --stats-every 15s -oA udp -iL $FILE | tee udp.out
}
