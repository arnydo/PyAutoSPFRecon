$TTL 3D
@       IN      SOA     autorecon.ns.kyleparrish.com. kyle@kyleparrish.com (
199802151       ; serial, todays date + todays serial #
21600              ; refresh, seconds
3600              ; retry, seconds
604800              ; expire, seconds
30 )            ; minimum, seconds
	NS	ns	; Inet Address of name server
localhost	 A       127.0.0.1
ns	A	165.227.125.5
