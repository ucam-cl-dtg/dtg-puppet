# Global configuration settings

Exec {
  path      => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
  logoutput => 'on_failure',
}

$org_domain = 'dtg.cl.cam.ac.uk'

$from_address = 'dtg-infra@cl.cam.ac.uk'

$ntp_servers = [ 'ntp2.csx.cam.ac.uk',
                 'ntp1.csx.cam.ac.uk',
                 'ntp1.retrosnub.co.uk',
                 'ntp1a.cl.cam.ac.uk',
                 'ntp1b.cl.cam.ac.uk',
                 'ntp1c.cl.cam.ac.uk', ]

$name_servers = [ '128.232.1.1',
                  '128.232.1.2',
                  '128.232.1.3' ]

# Id certifiers people who can sign other users keys to certify them
class ms_id_certifiers {
    monkeysphere::add_id_certifier { "drt24": keyid => "5017A1EC0B2908E3CF647CCD551435D5D74933D9" }
    monkeysphere::add_id_certifier { 'drt24-laptop': keyid => 'EA14782BFF32D5B8464B92D7B2FB14CF18EB83B1' }
}
# Admin users to be given an account on all machines
group { 'dtg-adm' :
  ensure => present
}
class admin_users {
    dtg::add_user { 'drt24':
        real_name => 'Daniel Thomas',
        groups    => [ 'adm', 'dtg-adm' ],
        keys      => 'Daniel Robert Thomas (Computer Lab Key) <drt24@cam.ac.uk>',
        uid       => 2607, 
    }
    dtg::add_user { 'oc243':
        real_name => 'Oliver Chick',
        groups    => [ 'adm', 'dtg-adm' ],
        keys      => 'Oliver Chick <oc243@cam.ac.uk>',
        uid       => 2834, 
    }
    dtg::add_user { 'lc525':
        real_name => 'Lucian Carata',
        groups    => ['adm'],
        keys      => 'Lucian Carata <lc525@cam.ac.uk>',
        uid       => 2925, 
    }
    dtg::add_user { 'jas250':
        real_name => 'James Snee',
        groups => ['adm'],
        keys   => 'James Snee <jas250@cam.ac.uk>',
        uid       => 2814, 
    }
    dtg::add_user { 'acr31':
        real_name  => 'Andrew Rice',
        groups     => ['adm', 'dtg-adm'],
        keys       => 'Andrew Rice <acr31@cam.ac.uk>',
        uid        => 2132, 
    }
    dtg::add_user { 'dtw30':
        real_name  => 'Daniel Wagner',
        groups     => ['adm'],
        keys       => 'Daniel Wagner (ssh) <wagner.daniel.t@gmail.com>',
        uid        => 2712,
    }
    dtg::add_user { 'ml421':
        real_name => 'Mattias Linnap',
        groups    => [ 'adm' ],
        keys      => ['Mattias Linnap <mattias@linnap.com>','Mattias Linnap (llynfi-ssh) <mattias@linnap.com>','Mattias Linnap (macmini-ssh) <mattias@linnap.com>'],
        uid        => 2610,
    }
    dtg::add_user { 'tb403':
	real_name => 'Thomas Bytheway',
	groups    => [ 'adm' ],
	keys	  => ['Thomas Bytheway <thomas.bytheway@cl.cam.ac.uk>'],
        uid        => 3105,        
    }
    dtg::add_user { 'arb33':
       real_name => 'Alastair Beresford',
       groups    => [ 'adm' ],
       keys	 => ['Alastair Beresford (ssh) <arb33@cam.ac.uk>'],
       uid       => 2125,        
    }
    dtg::add_user { 'ipd21':
       real_name => 'Ian Davies',
       groups    => [ 'adm' ],
       keys	 => ['Ian Davies (ssh) <ipd21@cam.ac.uk>'],
       uid       => 2361,        
    } 
    dtg::add_user { 'rss39':
      real_name => 'Ripduman Sohan',
      groups    => [ 'adm' ],
      keys      => ['Ripduman Sohan (Cambridge Key) <ripduman.sohan@cl.cam.ac.uk>'],
      uid       => 2134,
    }
    dtg::add_user { 'sa497':
      real_name => 'Sherif Akoush',
      groups    => [],
      keys      => [],
      uid       => 2412,
    }
    dtg::add_user { 'sac92':
      real_name => 'Stephen Cummins',
      groups    => [],
      keys      => ['Stephen Cummins (Main key) <sacummins@gmail.com>'],
      uid       => 3286,
    }
    
}
# Admin user ids to be given root on the nodes via monkeysphere
$ms_admin_user_ids = [
  "Daniel Robert Thomas (Computer Lab Key) <drt24@cam.ac.uk>"
]
# Keyserver with the public keys to use for monkeysphere
$ms_keyserver = 'keys.gnupg.net'
$ms_gpg_passphrase = 'not a secret passphrase - we rely on unix user protection'

# Nagios config
$nagios_machine_fqdn = "monitor.${org_domain}"
$nagios_server = "nagios.$org_domain"
$nagios_ssl = false
$nagios_from_emailaddress = $from_address
$nagios_alert_emailaddress = $nagios_from_emailaddress
$nagios_org_name = "Digitial Technology Group"
$nagios_org_url = "http://www.cl.cam.ac.uk/research/dtg/"

#Munin config
$munin_ssl = true
$munin_machine_fqdn = $nagios_machine_fqdn
$munin_server = "munin.$org_domain"
$munin_server_ip_array = dnsLookup($munin_server)
$munin_server_ip = $munin_server_ip_array[0]

if ( $::fqdn =~ /(monitor|prism).dtg.cl.cam.ac.uk/ ) {
  $monitor = true
} else {
  $monitor = false
}

# Unattended upgrade config
$unattended_upgrade_notify_emailaddress = $from_address

#Firewall config
$local_subnet = '128.232.0.0/16'
$dtg_subnet = '128.232.20.0/22'

# Backup config
$backup_hosts = 'nas01.dtg.cl.cam.ac.uk'

