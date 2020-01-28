#!/bin/bash
if [[ $1 = open ]]; then
    nmap -p 8881 192.168.255.1 >/dev/null
    nmap -p 7777 192.168.255.1 >/dev/null
    nmap -p 9991 192.168.255.1 >/dev/null
    echo "opened"
elif [[ $1 = close ]]; then
    nmap -p 7778 192.168.255.1 >/dev/null
    nmap -p 9992 192.168.255.1 >/dev/null
    nmap -p 8883 192.168.255.1 >/dev/null
    echo "closed"
else
    echo "ERR" >&2 && exit 1
fi

