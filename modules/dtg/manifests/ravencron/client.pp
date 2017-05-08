# Allow a cron job to ssh in and fill /home/ravencron/group-raven with
# releavnt cl groups to use for raven authentication.
class dtg::ravencron::client {
  group {'ravencron': ensure => present}
  #TODO(drt24) ravencron user is created so that it cannot be sshed into which is a bit useless.
  user {'ravencron':
    ensure => present,
    gid    => 'ravencron',
  }
  file {'/home/ravencron':
    ensure => directory,
    owner  => 'ravencron',
    group  => 'ravencron',
    mode   => '0755',
  }
  file {'/home/ravencron/bin/':
    ensure => directory,
    owner  => 'ravencron',
    group  => 'ravencron',
  }
  file {'/home/ravencron/bin/output.sh':
    ensure  => file,
    owner   => 'ravencron',
    group   => 'ravencron',
    mode    => '0755',
    content => '#!/bin/bash
cat - > ~/group-raven',
  }
  file {'/home/ravencron/.ssh/':
    ensure => directory,
    owner  => 'ravencron',
    group  => 'ravencron',
    mode   => '0755',
  }
  file {'/home/ravencron/.ssh/authorized_keys':
    ensure  => file,
    mode    => '0644',
    content => 'from="*.cl.cam.ac.uk",command="/home/ravencron/bin/output.sh" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCnA6kagBLZYgz82YiSXbrN4qJRhhRJp2oGUQPNVOIBtJ+rmZn/YQV/15KOhSUegyg852+vD3TGA/71ORam5yHj5nP6NdtvXXzBwnEgYQwijGgXOnc40DWq9NwUiJBK8yaMKlkAnEnSsZGt/v/68Sr1bGbGnGaB5XJ+BuMzu1iIp/YCcPGyMKKBGBIaovjY7LuxdL4h6NVh+aZyh2KFwt5BhXoNW93k9LFBgSSC+mBtSXAgx/L9yjXDCPqSNxhgPT+Q2YE/8DP25XbqfaZI0dFKgRWwOr4WkHBUU3p7RJx+6/gxbctHMWLLBFVYj2s4iRBPNTF4vSlzv5eAQm4Yb2aH open-room-map@ravenauthupdate',
  }
  # Specify the permissions and owner on the file to be filled by cron
  file {'/home/ravencron/group-raven':
    ensure => file,
    owner  => 'ravencron',
    group  => 'ravencron',
    mode   => '0664',
  }
}

