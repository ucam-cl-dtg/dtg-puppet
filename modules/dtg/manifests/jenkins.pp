class dtg::jenkins {
  class {'dtg::firewall::80to8080':}
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
  #TODO(drt24) Default to java7
  # Modify /etc/jenkins/debian_gule to point at precise and have main and universe components
  # Restore jenkins jobs from backups
}
# So that we can appy a stage to it
class dtg::jenkins::repos {
  apt::ppa {'ppa:ucam-cl-dtg/jenkins': }
}
