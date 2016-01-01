node 'oc243-algos' {
  class {'dtg::minimal':}
  class {'dtg::firewall::privatehttp':}
  class {'dtg::firewall::publichttps':}
  class {'dtg::firewall::80to8080':}
  class {'dtg::firewall::git':}

  file {'/local/data/gerrit':
    ensure    => directory,
    owner     => 'gerrit',
    group     => 'gerrit',
  }
  ->
  file {'/opt/gerrit':
    ensure => 'link',
    target => '/local/data/gerrit',
  }
  class {'apache::ubuntu': } ->
  class {'dtg::apache::raven': server_description => 'Part IA algorithms code review'}->
  apache::module {'proxy':} ->
  apache::module {'proxy_http':} ->
  apache::module {'ssl':} ->
  apache::module {'headers':} ->
  apache::module {'rewrite':} ->

  class {'gerrit':
    install_git => false,
    manage_firewall => false,
    manage_database => false,
    db_tag          => 'gerrit',
    gerrit_version => '2.12',
    override_secure_options => {
      'database'    => {
        type        => 'h2',
        hostname    => 'localhost',
        database    => 'gerrit',
        password    => 'gerrit',
      },
    },
    override_options => {
      'auth'        => {
        # Need to do some HACKs in apache config so that the headers are faked
        # up to look like http *basic* auth
        'type'      => 'http',
        # Email addresses should be crsid@cam.ac.uk
        'emailFormat' => '{0}@cam.ac.uk',
        'logoutUrl'   => 'https://raven.cam.ac.uk/auth/logout.html',
      },
      'container' => {
        'user'        => 'gerrit',
        'javaOptions' => '-classpath /usr/share/java/mysql.jar',
      },
      'gerrit'      => {
        'basePath'  => '/local/data/gerrit-data',
        'canonicalWebUrl' => 'http://puppy40.dtg.cl.cam.ac.uk'
      },
      'httpd' => {
        'listenUrl' => 'proxy-https://127.0.0.1:8081'
      },
      'sendemail' => {
        'smtpserver' => $smtp_server,
        'from'       => "Gerrit <$from_address>",
      },
      'user'     => {
        'email'   => $from_address,
      }
    }
  }
}
