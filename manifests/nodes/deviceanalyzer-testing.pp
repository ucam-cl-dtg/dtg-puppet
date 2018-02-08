node /deviceanalyzer-testing/ {
  include 'dtg::minimal'

  group { 'rd572' :
  }
  ->
  user { 'rd572':
    comment    => 'Ricardo Mendes <rscmendes@dei.uc.pt>',
    home       => '/home/rd572',
    shell      => '/bin/bash',
    groups     => ['adm','rd572'],
    membership => 'minimum',
    password   => '*',
  }
  ->
  file { '/home/rd572/':
    ensure => directory,
    owner  => 'rd572',
    group  => 'rd572',
    mode   => '0755',
  }
  ->
  file {'/home/rd572/.ssh/':
    ensure => directory,
    owner  => 'rd572',
    group  => 'rd572',
    mode   => '0700',
  }
  ->
  ssh_authorized_key {'rd572 key 1':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQC0+PCvDP1ZI6QVX12af2/NETzemDKNOsw2bz+NUdN77cfvOwZpAbh9zfdKBo1zDYV4VqOOyYkWOIffVR5ArTpJeyfvH7nw0ThM4L636tQ+uTpJlbu3DiJVL4d0lk1dqTAlKx01oLDOzD+3brVmtYj4TfaWfV+9+r9PMb8PXBA0Cgze6Z0U52OsTgO22R9LYtMqmNErFlxzZAi/wEdkopClyS0LaA+G6e8nJz/j+KnNW3YHt/UeHq7mh+Dcah2xe68suCoejvq4kcr5eK22I4nI/8Yn/CLjppg87kQ/13mPNC0wvXAbcqhbFbVMPMjHde4cQXWVk2YcN0p5T8WBvztiV2lkDc0CU2a8Q9dYfRxef7O0PZP8CzPpKI4xrGW89W/joPPvI1/40xa4dNlAxQkXK5gbVRQf5VTFyWG42DPMpUbOsCHMsmupeggt7NCEJYhyJ6ZiMDZsCXBPI8CIUMsusWok4xKDkXtnkTdZ7+NCa1xcOAHzBTVQD2uZrgDK1VijlU8Nb7JTBEk6tUsTmv2jr0SeMo5WoBq6Hg8T/MrtlScV/13glffk4xxQL71ZT1fL+69uIcbSbM84moa1nUthwiMv3+XzzQgeWBEo7RXukJdI0ekh0ueoUEsrkwaQM8FmPzlenv+uGTgp5rswfIRR6KIU1J0r18cfuHLXEYSJJQ==',
    user   => 'rd572',
    type   => 'ssh-rsa',
    name   => 'rscmendes@dei.uc.pt',
  }
  
  User<|title == jsp50 |> { groups +>[ 'adm' ] }
}

