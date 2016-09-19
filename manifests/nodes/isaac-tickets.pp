node 'isaac-tickets.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::publichttps':}
  class {'dtg::isaac':}

  $packages = ['rssh', 'inotify-tools',  'php5', 'libapache2-mod-php5', 'php5-mcrypt', 'zip', 'unzip', 'php5-mysql', 'php5-imap', 'php5-gd']
  package{$packages:
    ensure => installed
  }
  ->
  file_line { 'rssh-allow-sftp':
    line => 'allowsftp',
    path => '/etc/rssh.conf',
  }
  ->
  class {'apache::ubuntu': } ->
  class {'dtg::apache::raven': server_description => 'Isaac Physics'} ->
  apache::module {'cgi':} ->
  apache::module {'headers':} ->
  apache::module {'rewrite':} ->
  apache::module {'proxy':} ->
  apache::module {'proxy_http':} ->
  apache::module {'ssl':} ->
  apache::site {'isaac-tickets':
    source => 'puppet:///modules/dtg/apache/isaac-tickets.conf',
  } ->
  file { '/var/www-osticket':
    ensure => 'directory',
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0755',
  }
  ->
  exec { 'enable php imap':
    command => 'sudo php5enmod imap',
  }

  cron { 'osticket-cron':
    command => '/usr/bin/php /var/www-osticket/upload/api/cron.php',
    user    => www-data,
    minute  => '*/1'
  }

  # Database Backup
  file { '/local/data/isaac-tickets':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  ->
  cron {'isaac-backup-database':
    command => 'find /local/data/isaac-tickets/ -type f -prune -mtime +30 -exec rm -f {} \; ; mysqldump osticket | zip > /local/data/isaac-tickets/db_backup_`date +\%Y-\%m-\%d_\%H-\%M`.zip',
    user    => root,
    hour    => 0,
    minute  => 0
  }

}

if ( $::monitor ) {
  nagios::monitor { 'isaac-tickets-external':
    address                     => 'tickets.isaacphysics.org',
    hostgroups                  => [ 'http-servers', 'https-servers' ],
    include_standard_hostgroups => false,
  }
}


## For a new server, unpack osTicket.zip into /var/www-osticket, following instructions at http://osticket.com/wiki/Installation
## We also need MySQL:
##
##    sudo apt-get install mysql-server libapache2-mod-auth-mysql php5-mysql
##    sudo mysql_install_db
##    sudo /usr/bin/mysql_secure_installation
##
## Also create /root/.my.cnf with the content:
##
##    [mysqldump]
##    user=osticket
##    password=<whatever>
