/**
 * This defines the component that runs on the server to be backed up
 * backup_directory defines the directory to be backed up
 * script_destination is the destination to put the script which performs the
 *                    backup
 * user is the user to run as
 * home is the home directory of the user
 * backup_hosts is the comma separated list of hosts from which backups may be made for ssh from= line
 */
define dtg::backup::serversetup ($backup_directory, $script_destination, $user, $home, $backup_hosts = $::backup_hosts) {
  $backup_description = $name
  file {$script_destination:
    ensure  => file,
    owner   => $user,
    group   => $user,
    mode    => '0775',
    content => template('dtg/backup-server.sh.erb'),
  }
  $backup_hosts_from = join($backup_hosts, ',')
  file_line {"${name} backup authorized_keys":
    ensure  => present,
    line    => "from=\"${backup_hosts_from}\",command=\"${script_destination}\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzb/C7T6G+PQbVuc/uqp4YbBrMQ9JLoIrSPesNtSRlDg4ckrUIiWeAVt/NUYtIdE+7vl2YNbSU0IK8+ONsApnTNP+XjfEwjaIfZPwQRXtEGWCSs4QwN/ZihrhWNODYUP473HbOFvsVwBQSM7LxLBW6TB1ecjpPYC1ds1InOhJcfP752GqX5KkQ++mbUpb8YR6FQZTGiBKDD/LfD25PUblZkdp1kuiikD4GhMQrDmD1m+CycFpkK5l4idqNBohBA4RV9ton17kJHrD4gpZtYFwifRmdaXt6ageofw2GKM5MAMo5QNOezLDWDovOp4atHa1ZaUlCLF5or3QzNw+wHI9N git@code.dtg.cl.cam.ac.uk",
    path    => "${home}.ssh/authorized_keys",
    require => File["${home}.ssh/authorized_keys", $script_destination],
  }
}
# Configure a host to have a place and user for taking backups
class dtg::backup::host($directory, $user = 'backup', $home = undef, $key = undef) {
  if $home == undef {
    $realhome = "/home/${user}"
  } else {
    $realhome = $home
  }
  if $key == undef {
    $realkey = "${realhome}/.ssh/id_rsa"
  } else {
    $realkey = $key
  }
  group {"${user}":
    ensure => present,
  }
  user {"${user}":
    ensure   => present,
    password => "*",
    shell    => '/bin/sh',
    gid      => $user,
  }
  file{"${realhome}":
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
  }
  file{"${realhome}/.ssh":
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0700',
  }
  file{"${directory}":
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0701',#Backups should not be readable by anyone else - needs to be executable for 'others'
  }
  # Set sending address for $user to dtg-infra
  file_line {"${user}email":
    ensure => present,
    path   => '/etc/email-addresses',
    line   => "${user}: dtg-infra@cl.cam.ac.uk",
    require => [Package['exim'],User[$user]],
  }
}

# The mirror of dtg::backup::serversetup this configures the backup host to take backups
# of a server which has been setup.
# The name of the backup will be used as the directory name for the subdir containing the backups
# user is the user to ssh in as
# host is the host to ssh into
define dtg::backup::hostsetup($user, $group = $dtg::backup::host::user, $host, $weekday) { #needs to have a configurable backup group + default
  $backupsdirectory = $dtg::backup::host::directory
  $backupsuser      = $dtg::backup::host::user
  $backupskey       = $dtg::backup::host::realkey
  $backupto = "${backupsdirectory}/${name}"

  file {"${backupto}":
    ensure => directory,
    owner  => $backupsuser,
    group  => $group,
    mode   => '0700',
  }
  cron {"backup ${name}":
    ensure  => present,
    user    => $backupsuser,
    environment => "MAILTO=dtg-infra@cl.cam.ac.uk",
    command => "nice -n 19 /bin/bash -c 'ssh -T -i ${backupskey} ${user}@${host} > ${backupto}/`date +\\%F_\\%T`.tar.bz2'",
    minute  => cron_minute("backup ${name}"),
    hour    => cron_hour("backup ${name}"),
    weekday => $weekday,
    require => File["${backupto}"],
  }
}
