node "nas04.dtg.cl.cam.ac.uk" {
  include 'dtg::minimal'
  include 'nfs::server'
  
  class {'dtg::zfs'}
  
  class {'zfs_auto_snapshot':
    pool_names => [ 'dtg-pool' ]
  }

}
