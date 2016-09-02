define dtg::backup::serversetup_script ($content, $script_destination, $user, $home, $backup_hosts = $::backup_hosts) {
  $backup_description = $name
  file {$script_destination:
    ensure  => file,
    owner   => $user,
    group   => $user,
    mode    => '0775',
    content => $content
  }
  $backup_hosts_from = join($backup_hosts, ',')
  file_line {"${name} backup authorized_keys":
    ensure  => present,
    line    => "from=\"${backup_hosts_from}\",command=\"${script_destination}\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzb/C7T6G+PQbVuc/uqp4YbBrMQ9JLoIrSPesNtSRlDg4ckrUIiWeAVt/NUYtIdE+7vl2YNbSU0IK8+ONsApnTNP+XjfEwjaIfZPwQRXtEGWCSs4QwN/ZihrhWNODYUP473HbOFvsVwBQSM7LxLBW6TB1ecjpPYC1ds1InOhJcfP752GqX5KkQ++mbUpb8YR6FQZTGiBKDD/LfD25PUblZkdp1kuiikD4GhMQrDmD1m+CycFpkK5l4idqNBohBA4RV9ton17kJHrD4gpZtYFwifRmdaXt6ageofw2GKM5MAMo5QNOezLDWDovOp4atHa1ZaUlCLF5or3QzNw+wHI9N git@code.dtg.cl.cam.ac.uk",
    path    => "${home}.ssh/authorized_keys",
    require => File["${home}.ssh/authorized_keys", $script_destination],
  }
}
