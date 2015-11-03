class dtg::jenkins {
  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::80to8080': private => false}
  class {'dtg::tomcat::raven':}
  class {'dtg::jenkins::repos': stage => 'repos'}
  $tomcat_version = '8'
  # To help build debian packages in jenkins
  package {'jenkins-debian-glue':
    ensure  => present,
    require => Apt::Ppa['ppa:ucam-cl-dtg/jenkins'],
  }
  #packages required by jenkins jobs
  $jenkins_job_packages = [# One line per job's install list
    'graphviz',
    'inkscape',
    'openjdk-7-jdk',
    'reprepro','git-buildpackage', 'build-essential', 'cowbuilder', 'cowdancer', 'debootstrap','devscripts','pbuilder',
    'octave', 'octave-octgpr',
    'mysql-common',
    'maven',
    'postgresql-client-common','postgresql-client-9.4',
    'jenkins-crypto-util', 'jenkins-external-job-monitor', 'jenkins-instance-identity', 'jenkins-memory-monitor', 'jenkins-ssh-cli-auth',
    'python3-markdown', 'mercurial', 'python3-urllib3', 'python3-dateutil', 'python3-numpy', 'python3-uncertainties', # For AVO
    'python3-matplotlib', 'python3-scipy', 'python3-cairo', 'python3-cairocffi', 'vnc4server', 'fluxbox', 'python3-dev', 'python3-jsonpickle', # for da-graphing
    'ghc', 'cabal-install', 'liblapack3', # for camfort
    ]
  package { $jenkins_job_packages:
    ensure => installed,
  }
  # Invoking Haskell package manager to install CamFort dependencies
  ->
  file {[
    "/usr/share/tomcat${tomcat_version}/.cabal/",
    "/usr/share/tomcat${tomcat_version}/.ghc/",
    ]:
    ensure  => directory,
    owner   => "tomcat${tomcat_version}",
    group   => "tomcat${tomcat_version}",
    mode    => '0700'
  } ->
  exec {'update-cabal':
    user        => "tomcat${tomcat_version}",
    environment => "HOME=/usr/share/tomcat${tomcat_version}",
    command     => '/usr/bin/cabal update',
  }
  #packages required by jenkins
  package {['jenkins-tomcat','jenkins-cli']:
    ensure => installed,
  }
  # Package installation actually creates this user and group
  group {"tomcat${tomcat_version}":
    ensure  => present,
    require => Package['jenkins-tomcat'],
  }
  user  {"tomcat${tomcat_version}":
    ensure => present,
    gid    => "tomcat${tomcat_version}",
  }
  sudoers::allowed_command{ 'jenkins':
    command          => '/usr/sbin/cowbuilder, /usr/sbin/chroot',
    user             => "tomcat${tomcat_version}",
    require_password => false,
    comment          => 'Allow tomcat to build debian packages using cowbuilder in a chroot',
  }
  file { "/usr/share/tomcat${tomcat_version}/.config/":
    ensure  => directory,
    owner   => "tomcat${tomcat_version}",
    group   => "tomcat${tomcat_version}",
    mode    => '0775',
    require => Package['jenkins-tomcat'],
  }
  file { "/usr/share/tomcat${tomcat_version}/.m2/":
    ensure  => directory,
    owner   => "tomcat${tomcat_version}",
    group   => "tomcat${tomcat_version}",
    mode    => '0775',
    require => Package['jenkins-tomcat'],
  }
  file { "/usr/share/tomcat${tomcat_version}/.android/":
    ensure => directory,
    owner  => "tomcat${tomcat_version}",
    group  => "tomcat${tomcat_version}",
    mode   => '0775',
  }
  file { "/usr/share/tomcat${tomcat_version}/.ssh/":
    ensure => directory,
    owner  => "tomcat${tomcat_version}",
    group  => "tomcat${tomcat_version}",
    mode   => '0700',
  }
  file { "/usr/share/tomcat${tomcat_version}/.ssh/config":
    ensure => file,
    owner  => "tomcat${tomcat_version}",
    group  => "tomcat${tomcat_version}",
    mode   => '0644',
  }
  file { "/usr/share/tomcat${tomcat_version}/.jenkins":
    ensure => directory,
    owner  => "tomcat${tomcat_version}",
    group  => "tomcat${tomcat_version}",
    mode   => '0775',
  }
  file { "/usr/share/tomcat${tomcat_version}/.jenkins/cache":
    ensure => directory,
    owner  => "tomcat${tomcat_version}",
    group  => "tomcat${tomcat_version}",
    mode   => '0775',
  }
  file { "/usr/share/tomcat${tomcat_version}/.jenkins/cache/jars":
    ensure => directory,
    owner  => "tomcat${tomcat_version}",
    group  => "tomcat${tomcat_version}",
    mode   => '0775',
  }

# Set up a redirect to the jenkins app
  file { "/var/lib/tomcat${tomcat_version}/webapps/ROOT/index.html":
    ensure => absent,
  }
  file { "/var/lib/tomcat${tomcat_version}/webapps/ROOT/index.jsp":
    ensure  => file,
    content => '<%
response.sendRedirect("http://dtg-ci.cl.cam.ac.uk/jenkins/");
%>',
    owner   =>  "tomcat${tomcat_version}",
    group   => "tomcat${tomcat_version}",
    mode    => '0644',
  }

  file { '/srv/repository/':
    ensure => directory,
    owner  => "tomcat${tomcat_version}",
    group  => "tomcat${tomcat_version}",
    mode   => '0775',
  }

  # For AVO
  vcsrepo { '/opt/poole':
    ensure   => present,
    provider => 'hg',
    source   => 'http://bitbucket.org/obensonne/poole/',
    revision => 'py3',
  } ->
  file { '/usr/local/bin/poole.py':
    ensure => link,
    target => '/opt/poole/poole.py',
  } ->
  file_line { 'poole python 3':
    path  => '/opt/poole/poole.py',
    line  => '#!/usr/bin/env python3',
    match => '^#!/usr/bin/env python',
  }

  # For DA
  package {'autofs':
    ensure => present,
  } ->
  file {'/etc/auto.nas04':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => 'a=r',
    content => 'deviceanalyzer   nas04.dtg.cl.cam.ac.uk:/dtg-pool0/deviceanalyzer
deviceanalyzer-graphing   nas04.dtg.cl.cam.ac.uk:/dtg-pool0/deviceanalyzer-graphing',
  } ->
  file_line {'mount nas04':
    line => '/mnt/nas04   /etc/auto.nas04',
    path => '/etc/auto.master',
  }

  #TODO(drt24) Default to java7
  # Modify /etc/jenkins/debian_glue to point at precise and have main and universe components
  # Restore jenkins jobs from backups
  # /usr/share/tomcat${tomcat_version}/{.ssh/{id_rsa,id_rsa.pub},.m2/settings.xml,.android/debug.keystore} need to be got from secrets server
}
# So that we can appy a stage to it
class dtg::jenkins::repos {
  apt::ppa {'ppa:ucam-cl-dtg/jenkins': }
}
