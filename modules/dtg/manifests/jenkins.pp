class dtg::jenkins {
  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::80to8080': private => false}
  class {'dtg::tomcat::raven':}
  class {'dtg::jenkins::repos': stage => 'repos'}
  # To help build debian packages in jenkins
  package {'jenkins-debian-glue':
    ensure => present,
    require => Apt::Ppa['ppa:ucam-cl-dtg/jenkins'],
  }
  #packages required by jenkins jobs
  $jenkins_job_packages = ['inkscape','openjdk-7-jdk','reprepro','git-buildpackage', 'build-essential', 'cowbuilder', 'cowdancer', 'debootstrap','devscripts','pbuilder', 'octave', 'octave-octgpr', 'mysql-common','maven']
  package { $jenkins_job_packages:
    ensure => installed,
  }
  #packages required by jenkins
  package {['jenkins-tomcat','jenkins-cli']:
    ensure => installed,
  }
  # Package installation actually creates this user and group
  group {'tomcat6':
    ensure  => present,
    require => Package['jenkins-tomcat'],
  }
  user  {'tomcat6':
    ensure => present,
    gid    => 'tomcat6',
  }
  sudoers::allowed_command{ 'jenkins':
    command          => '/usr/sbin/cowbuilder, /usr/sbin/chroot',
    user             => 'tomcat6',
    require_password => false,
    comment          => 'Allow tomcat to build debian packages using cowbuilder in a chroot',
  }
  file { '/usr/share/tomcat6/.config/':
    ensure => directory,
    owner  => 'tomcat6',
    group  => 'tomcat6',
    mode   => '0775',
    require => Package['jenkins-tomcat'],
  }
  file { '/usr/share/tomcat6/.m2/':
    ensure => directory,
    owner  => 'tomcat6',
    group  => 'tomcat6',
    mode   => '0775',
    require => Package['jenkins-tomcat'],
  }
  file { '/usr/share/tomcat6/.android/':
    ensure => directory,
    owner  => 'tomcat6',
    group  => 'tomcat6',
    mode   => '0775',
  }
  file { '/usr/share/tomcat6/.ssh/':
    ensure => directory,
    owner  => 'tomcat6',
    group  => 'tomcat6',
    mode   => '0700',
  }
  file { '/usr/share/tomcat6/.ssh/config':
    ensure => file,
    owner  => 'tomcat6',
    group  => 'tomcat6',
    mode   => '0644',
  }
  #TODO(drt24) Default to java7
  # Modify /etc/jenkins/debian_glue to point at precise and have main and universe components
  # Restore jenkins jobs from backups
  # /usr/share/tomcat6/{.ssh/{id_rsa,id_rsa.pub},.m2/settings.xml,.android/debug.keystore} need to be got from secrets server
}
# So that we can appy a stage to it
class dtg::jenkins::repos {
  apt::ppa {'ppa:ucam-cl-dtg/jenkins': }
}
