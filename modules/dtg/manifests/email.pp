# Set up email related config - exim et. al.
class dtg::email {
  # Make it possible to send email (if correct from address is used)
  class { 'exim::satellite':
    smarthost   => 'mail-serv.cl.cam.ac.uk',
    mail_domain => 'cl.cam.ac.uk',
  }
  # Set sending address for root to dtg-infra
  file_line {'rootemail':
    ensure  => present,
    path    => '/etc/email-addresses',
    line    => 'root: dtg-infra@cl.cam.ac.uk',
    require => Package['exim'],
  }

  # Set mailto for cron job emails
  augeas {'rootcrontabmailtoinsert':
    incl    => '/etc/crontab',
    lens    => 'Cron.lns',
    changes => ['ins MAILTO after SHELL', 'set MAILTO dtg-infra@cl.cam.ac.uk'],
    onlyif  => 'match MAILTO size == 0',
  }

  augeas {'rootcrontabmailtoset':
    incl    => '/etc/crontab',
    lens    => 'Cron.lns',
    changes => 'set MAILTO dtg-infra@cl.cam.ac.uk',
    onlyif  => 'get MAILTO != dtg-infra@cl.cam.ac.uk',
    require => Augeas['rootcrontabmailtoinsert'],
  }
}
