# This node hosts the webserver for receiving uploads as well as providing the main website for the SensorID project

node 'sensorid-www.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  class {'dtg::firewall::privatehttp':}
  class {'dtg::firewall::privatehttps':}
  class {'dtg::firewall::80to5000':}
  
  # Packages which should be installed
  $packagelist = ['nginx']
  package {
    $packagelist:
      ensure => installed
  }
  
  User<|title == jz448 |> { groups +>[ 'adm' ] }
}