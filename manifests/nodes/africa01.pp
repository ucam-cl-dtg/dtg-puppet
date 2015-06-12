node 'africa01.cl.cam.ac.uk' {  
  include 'nfs::server'
  
  class {'dtg::zfs': }

}
