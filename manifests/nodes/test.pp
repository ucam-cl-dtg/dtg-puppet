node 'test-puppet.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

# Make accessible over http and https
  class {'dtg::firewall::publichttp':} ->
  class {'dtg::firewall::publichttps':} ->

# Install apache and configure the site
  class {'apache': } ->
  apache::module {'ssl':} ->
  apache::module {'headers':} ->
  apache::site{'test':
    source => 'puppet:///modules/dtg/apache/test.conf'
  } ->

# Use letsencrypt to get a certificate
  class {'letsencrypt':
    email => $::from_address,
  } ->
  letsencrypt::certonly { $::fqdn:
    plugin      => 'webroot',
    webroot_paths => ['/var/www/html/'],
    manage_cron => true,
  }

}
if ( $::monitor ) {
  munin::gatherer::configure_node { 'test-puppet': }
}
