Exec { path => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin' }
$ntp_servers = [ 'ntp2.csx.cam.ac.uk',
                 'ntp1.csx.cam.ac.uk',
                 'ntp1.retrosnub.co.uk',
                 'ntp1a.cl.cam.ac.uk',
                 'ntp1b.cl.cam.ac.uk',
                 'ntp1c.cl.cam.ac.uk', ]
# Id certifiers people who can sign other users keys to certify them
class ms_id_certifiers {
    monkeysphere::add_id_certifier { "drt24": keyid => "5017A1EC0B2908E3CF647CCD551435D5D74933D9" }
}
# Admin user ids to be given root on the nodes via monkeysphere
$ms_admin_user_ids = [
  "Daniel Robert Thomas (Computer Lab Key) <drt24@cam.ac.uk>"
]
# Keyserver with the public keys to use for monkeysphere
$ms_keyserver = 'keys.gnupg.net'
