# This defines the component that runs on the server to be backed up
# backup_directory defines the directory to be backed up
# script_destination is the destination to put the script which performs the
#                    backup
# user is the user to run as
# home is the home directory of the user
# backup_hosts is the comma separated list of hosts from which backups may be made for ssh from= line
define dtg::backup::serversetup ($backup_directory, $script_destination, $user, $home, $backup_hosts = $::backup_hosts) {
  $backup_description = $name
  dtg::backup::serversetup_script { "${name} script":
    content            => template('dtg/backup-server.sh.erb'),
    script_destination => $script_destination,
    user               => $user,
    home               => $home,
    backup_hosts       => $backup_hosts,
  }
}
