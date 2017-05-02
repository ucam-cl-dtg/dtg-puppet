# VM for akmf3 bigdata analytics project


node 'bda.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  User<|title == akmf3 |> { groups +>[ 'dtg' ] }
  
}