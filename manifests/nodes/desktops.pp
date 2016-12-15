$grapevine_ips = dnsLookup('grapevine.cl.cam.ac.uk')
$grapevine_ip = $grapevine_ips[0]
$earlybird_ips = dnsLookup('earlybird.cl.cam.ac.uk')
$earlybird_ip = $earlybird_ips[0]
$desktop_ips = "${grapevine_ip},${earlybird_ip}"
$desktop_ips_array = [$grapevine_ip, $earlybird_ip]
