#!/bin/sh
/usr/sbin/dnsmasq -C /etc/dnsmasq.conf -k --dhcp-broadcast --log-facility=/proc/1/fd/1
