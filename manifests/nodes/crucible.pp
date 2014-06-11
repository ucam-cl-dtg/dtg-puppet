node 'crucible.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  User<|title == sac92 |> { groups +>[ 'adm' ] }

  package {['openjdk-7-jdk']:
    ensure => installed
  }
}
