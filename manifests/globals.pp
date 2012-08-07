Exec { path => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin' }
$ntp_servers = [ 'ntp2.csx.cam.ac.uk',
                 'ntp1.csx.cam.ac.uk',
                 'ntp1.retrosnub.co.uk',
                 'ntp1a.cl.cam.ac.uk',
                 'ntp1b.cl.cam.ac.uk',
                 'ntp1c.cl.cam.ac.uk', ]
# Admin user ids to be given root on the nodes via monkeysphere
$ms_admin_user_ids = [
  "Daniel Robert Thomas (Computer Lab Key) <drt24@cam.ac.uk>"
]
# Keyserver with the public keys to use for monkeysphere
$ms_keyserver = 'keys.gnupg.net'
