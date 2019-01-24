# VM for md403 ICS analysis project
node 'md403-ics.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  $packages = ['python3-pandas', 'python3-matplotlib', 'python3-pip']
  package{$packages:
    ensure => installed,
  }
  User<|title == md403 |> { groups +>[ 'adm' ] }
}
