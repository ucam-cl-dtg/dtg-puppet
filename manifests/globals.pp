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
# Id certifiers people who can sign other users keys to certify them
class ms_id_certifiers {
    monkeysphere::add_id_certifier { "drt24": keyid => "5017A1EC0B2908E3CF647CCD551435D5D74933D9" }
    monkeysphere::add_id_certifier { 'drt24-laptop': keyid => 'EA14782BFF32D5B8464B92D7B2FB14CF18EB83B1' }
}
# Admin users to be given an account on all machines
class admin_users {
    dtg::add_user { 'drt24':
        real_name => 'Daniel Thomas',
        groups    => [ 'adm' ],
        keys      => 'Daniel Robert Thomas (Computer Lab Key) <drt24@cam.ac.uk>',
    }
    dtg::add_user { 'oc243':
        real_name => 'Oliver Chick',
        groups    => [ 'adm' ],
        keys      => 'Oliver Chick <oc243@cam.ac.uk>',
    }
    dtg::add_user { 'lc525':
        real_name => 'Lucian Carata',
        groups    => ['adm'],
        keys      => 'Lucian Carata <lc525@cam.ac.uk>',
    }
    dtg::add_user { 'jas250':
        real_name => 'James Snee',
        groups => ['adm'],
        keys   => 'James Snee <jas250@cam.ac.uk>',
    }
    dtg::add_user { 'acr31':
        real_name  => 'Andrew Rice',
        groups     => ['adm'],
        keys       => 'Andrew Rice <acr31@cam.ac.uk>',
    }
    dtg::add_user { 'dtw30':
        real_name  => 'Daniel Wagner',
        groups     => ['adm'],
        keys       => 'Daniel Wagner (ssh) <wagner.daniel.t@gmail.com>',
    }
    # Add Mattias but don't make him an admin
    dtg::add_user { 'ml421':
        real_name => 'Mattias Linnap',
        keys      => ['Mattias Linnap <mattias@linnap.com>','Mattias Linnap (llynfi-ssh) <mattias@linnap.com>','Mattias Linnap (macmini-ssh) <mattias@linnap.com>'],
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
$munin_ssl = false
$munin_machine_fqdn = $nagios_machine_fqdn
$munin_server = "munin.$org_domain"
$munin_server_ip_array = dnsLookup($munin_server)
$munin_server_ip = $munin_server_ip_array[0]

# Unattended upgrade config
$unattended_upgrade_notify_emailaddress = $from_address

#Firewall config
$local_subnet = '128.232.0.0/16'
