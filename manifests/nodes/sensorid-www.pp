# This node hosts the webserver for receiving uploads as well as providing the main website for the SensorID project

node 'sensorid-www.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  class {'dtg::firewall::publichttp':}
  class {'dtg::firewall::publichttps':}
  
  # Packages which should be installed
  $packagelist = ['nginx']
  package {
    $packagelist:
      ensure => installed
  }
  
  User<|title == jz448 |> { groups +>[ 'adm' ] }
}