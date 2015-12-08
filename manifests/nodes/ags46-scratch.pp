node 'ags46-scratch.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  User<|title == ags46 |> {
  	groups +>[ 'adm' ]
  }

  dtg::sudoers_group{ 'isaac':
    group_name => 'isaac',
  }

}
