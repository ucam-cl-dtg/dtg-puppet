# The mirror of dtg::backup::serversetup this configures the backup host to take backups
# of a server which has been setup.
# The name of the backup will be used as the directory name for the subdir containing the backups
# user is the user to ssh in as
# host is the host to ssh into
define dtg::backup::hostsetup($user, $host, $weekday, $group = $dtg::backup::host::user) { #needs to have a configurable backup group + default
  $backupsdirectory = $dtg::backup::host::directory
  $backupsuser      = $dtg::backup::host::user
  $backupskey       = $dtg::backup::host::realkey
  $backupto = "${backupsdirectory}/${name}"

  file {$backupto:
    ensure => directory,
    owner  => $backupsuser,
    group  => $group,
    mode   => 'u=rwx,g=rx,o=x',
  }
  cron {"backup ${name}":
    ensure      => present,
    user        => $backupsuser,
    environment => 'MAILTO=dtg-infra@cl.cam.ac.uk',
    command     => "nice -n 19 /bin/bash -c 'ssh -T -i ${backupskey} ${user}@${host} > ${backupto}/`date +\\%F_\\%T`.tar.bz2'",
    minute      => cron_minute("backup ${name}"),
    hour        => cron_hour("backup ${name}"),
    weekday     => $weekday,
    require     => File[$backupto],
  }
}
