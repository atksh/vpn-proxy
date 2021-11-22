#!/bin/bash
if [ -z "$CERT" ]
then
  echo $ANYCONNECT_PASSWORD|openconnect $ANYCONNECT_SERVER --user=$ANYCONNECT_USER -b
else
  echo $ANYCONNECT_PASSWORD|openconnect $ANYCONNECT_SERVER --user=$ANYCONNECT_USER --servercert=$CERT -b
fi

while ! ip link show | grep -q "tun0"; do
    echo "Initializing the tunnel"
    sleep 2
done
echo "Tunnel is ready!"

/usr/sbin/danted -f /etc/danted.conf -D

socat -d TCP4-LISTEN:3389,fork TCP4:$JUMP1:3389 &
socat -d TCP4-LISTEN:3390,fork TCP4:$JUMP2:3389 &

/bin/bash
