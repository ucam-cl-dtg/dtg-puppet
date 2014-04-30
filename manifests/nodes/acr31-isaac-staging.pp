node 'isaac-staging.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  User<|title == sac92 |> { groups +>[ 'adm' ]}

}
