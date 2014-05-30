# VM for dac53's Mphil project
node "dac53.dtg.cl.cam.ac.uk" {
  include 'dtg::minimal'
  dtg::add_user { 'dac53':
    real_name => 'Diana Crisan',
    groups    => [ 'adm' ],
    keys      => '',
    uid       => 3252,
  } ->
  ssh_authorized_key {'dac53 key':
    ensure => present,
    key => 'AAAAB3NzaC1kc3MAAACBAJbJThHwoXG1li+qJsBehCIXL72kHgqoJc7wWD31/QI6uV+9sK9XE8cQ0bbFN5ZlqoVukXZ7Zlbnn2UVYfQ0ADuH6olXtoFHLbnxnMHXmK0yBEKeyr23tQqzd2hbSd4tCghohdUzODl3xpy/esd7vXbHPUrMGReqEg66D5C22vdZAAAAFQC4d9NGZ7bJgRsG72Ll7mAEGb/kCwAAAIAoq64zMHDLVRXPup/PupSxecBCe+Q4NjSkmAM/PcpLoLXTpECUNNCVnE2eenFMGsuq7BAccoVnmLsCgMK/SdZFTWhi6I4UjD80Vb/1VaO4r6VMhn6ptxWqoBq5YY37/4tIIw20cCiY6kmg/8lBAnIrw8w1CRq82dYuIEH+xid3EwAAAIBU4eHWGBjD20zSPbgDRYWmtwVb/tLC8Ua5oF+d77wtYdwOHn531cAiB41VL2YTraFFCT5zV5Z5kU1NAsofsXEWl364xEpscuohtONE0hsDcaoC5OyIFiQ6j7HJRIpYJO3hWaeULd0MAIc8D117SQqTRj+UU0xDaNTOP2b4H6DXCw==',
    user => 'dac53',
    type => 'ssh-dss',
  }
}
if ( $::monitor ) {
  nagios::monitor { 'dac53':
    parents    => 'nas04',
    address    => 'dac53.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
  munin::gatherer::configure_node { 'dac53': }
}
