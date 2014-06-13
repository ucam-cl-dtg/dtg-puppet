$grapevine_ips = dnsLookup('grapevine.cl.cam.ac.uk')
$grapevine_ip = $grapevine_ips[0]
$shin_ips = dnsLookup('shin.cl.cam.ac.uk')
$shin_ip = $shin_ips[0]
$earlybird_ips = dnsLookup('earlybird.cl.cam.ac.uk')
$earlybird_ip = $earlybird_ips[0]
$desktop_ips = "$grapevine_ip,$shin_ip,$earlybird_ip"
