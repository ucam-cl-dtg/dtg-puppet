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
  file_line {"${name} backup authorized_keys":
    ensure  => present,
    line    => "from=\"${backup_hosts}\",command=\"${script_destination}\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzb/C7T6G+PQbVuc/uqp4YbBrMQ9JLoIrSPesNtSRlDg4ckrUIiWeAVt/NUYtIdE+7vl2YNbSU0IK8+ONsApnTNP+XjfEwjaIfZPwQRXtEGWCSs4QwN/ZihrhWNODYUP473HbOFvsVwBQSM7LxLBW6TB1ecjpPYC1ds1InOhJcfP752GqX5KkQ++mbUpb8YR6FQZTGiBKDD/LfD25PUblZkdp1kuiikD4GhMQrDmD1m+CycFpkK5l4idqNBohBA4RV9ton17kJHrD4gpZtYFwifRmdaXt6ageofw2GKM5MAMo5QNOezLDWDovOp4atHa1ZaUlCLF5or3QzNw+wHI9N git@dtg-code.cl.cam.ac.uk",
    path    => "${home}.ssh/authorized_keys",
    require => File["${home}.ssh/authorized_keys", $script_destination],
  }
}
