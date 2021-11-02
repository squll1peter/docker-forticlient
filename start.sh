#!/bin/sh

if [ -z "$VPNADDR" -o -z "$VPNUSER" -o -z "$VPNPASS" -o -z "$DESTIP" -o -z "$DESTPORT" ]; then
  echo "Variables VPNRDPIP, VPNADDR, VPNUSER and VPNPASS must be set."; exit;
fi

export VPNTIMEOUT=${VPNTIMEOUT:-5}

iptables -t nat -A PREROUTING -p tcp --dport 3380 -j DNAT --to-destination  ${DESTIP}:${DESTPORT}
iptables -t nat -A POSTROUTING -j MASQUERADE

# Setup masquerade, to allow using the container as a gateway
for iface in $(ip a | grep eth | grep inet | awk '{print $2}'); do
  iptables -t nat -A POSTROUTING -s "$iface" -j MASQUERADE
done

 mknod /dev/ppp c 108 0

while [ true ]; do
  echo "------------ VPN Starts ------------"
  /usr/bin/forticlient
  echo "------------ VPN exited ------------"
  sleep 10
  
  #If not set then exit
  if [ $Reconnect != "true" ] || [ $Reconnect != "TRUE" ]; then
    exit;
  fi
  
done
