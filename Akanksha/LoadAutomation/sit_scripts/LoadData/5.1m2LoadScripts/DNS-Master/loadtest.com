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

loadtest.com.		IN A     127.0.0.1
;as1			IN A    10.145.0.46 
as1			IN A    10.145.0.117

; SRV records section
; SRV records section
;_sip._udp.as SRV 1 1 5060 as1.sittest.com.
_sip._udp.as SRV 1 1 5060 as1.loadtest.com.
;_sips._tcp.as.sittest.com. SRV 1 1 5061 as2.sittest.com.
;_sip._udp.as.sittest.com. SRV 1 1 5060 as1.sittest.com.
;_sip._udp.as.sittest.com. SRV 2 1 5060 as2.sittest.com.
;_sip._tcp.as.sittest.com. SRV 1 1 5060 as1.sittest.com.


;_sips._tcp.sittest.com.  43200 IN SRV 0 0 5061  as2.sittest.com.
;_sip._udp.sittest.com.   43200 IN SRV 0 0 5060  as2.sittest.com.
;_sip._tcp.sittest.com.   43200 IN SRV 0 0 5060  as2.sittest.com.

; NAPTR records section
;sittest.com. IN NAPTR 0 0 "s" "SIPS+D2T" "" _sips._tcp.sittest.com.
;sittest.com. IN NAPTR 1 0 "s" "SIP+D2T"  "" _sip._tcp.sittest.com.
;sittest.com. IN NAPTR 2 0 "s" "SIP+D2U"  "" _sip._udp.sittest.com.

