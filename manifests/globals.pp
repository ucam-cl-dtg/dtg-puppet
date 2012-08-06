$ntp_servers = [ 'server ntp2.csx.cam.ac.uk',
                 'server ntp1.csx.cam.ac.uk',
                 'server ntp1.retrosnub.co.uk',
                 'server ntp1a.cl.cam.ac.uk',
                 'server ntp1b.cl.cam.ac.uk',
                 'server ntp1c.cl.cam.ac.uk', ]
# Admin user ids to be given root on the nodes via monkeysphere
$ms_admin_user_ids = [
  "Daniel Thomas <drt24@cam.ac.uk>"
]
# Keyserver with the public keys to use for monkeysphere
$ms_keyserver = 'keys.gnupg.net'
