$TTL 3D
@	IN SOA	server2.qalab.net. root.server2.qalab.net. ( 
			200408241	; Serial
			10800		; Refresh
			3600		; Retry
			604800		; Expire
			86400 )		; Minimum TTL

; Name servers 
			IN NS	server2.qalab.net.

; Localhost Record 
localhost		IN A	127.0.0.1

; Name to Address Records 
; FQDN is needed for the domain name address record to allow zone transfers 

load52test2.com.		IN A     127.0.0.1
as1			IN A    10.148.0.91 

; SRV records section
_sip._udp.as SRV 1 1 5060 as1.load52test2.com.
;_sip._tcp.as.syschar.com. SRV 1 1 5060 as1.syschar.com.

; NAPTR records section
;syschar.com. IN NAPTR 0 0 "s" "SIPS+D2T" "" _sips._tcp.syschar.com.
;syschar.com. IN NAPTR 1 0 "s" "SIP+D2T"  "" _sip._tcp.syschar.com.
;syschar.com. IN NAPTR 2 0 "s" "SIP+D2U"  "" _sip._udp.syschar.com.

