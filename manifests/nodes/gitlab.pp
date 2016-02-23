node 'gitlab.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  class {'dtg::scm':}
  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::publichttps':} ->


# Use letsencrypt to get a certificate
  class {'letsencrypt':
    email => $::from_address,
  } ->
  letsencrypt::certonly { $::fqdn:
    plugin      => 'webroot',
    webroot_paths => ['/srv/git/gitlab/public/'],
    manage_cron => true,
  }



}
if ( $::monitor ) {
  nagios::monitor { 'gitlab':
    parents    => 'nas04',
    address    => 'gitlab.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers'],
  }
  munin::gatherer::configure_node { 'gitlab': }
}
