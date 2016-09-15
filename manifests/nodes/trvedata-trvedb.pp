# VM for the TRVE Data Project to test the trvedb implementation 
node 'trvedata-trvedb.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  User<|title == mk428 |> { groups +>[ 'adm' ] }
}
