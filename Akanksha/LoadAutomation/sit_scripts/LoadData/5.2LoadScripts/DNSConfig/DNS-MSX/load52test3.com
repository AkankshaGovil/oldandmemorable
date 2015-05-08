$ORIGIN .
$TTL 259200	; 3 days
load52test3.com		IN SOA	server2.qalab.net. root.server2.qalab.net. (
				200408241  ; serial
				10800      ; refresh (3 hours)
				3600       ; retry (1 hour)
				604800     ; expire (1 week)
				86400      ; minimum (1 day)
				)
			NS	server2.qalab.net.
			A	127.0.0.1
$ORIGIN load52test3.com.
_sip._udp.as		SRV	1 1 5060 as1
as1			A	10.148.0.94
localhost		A	127.0.0.1
