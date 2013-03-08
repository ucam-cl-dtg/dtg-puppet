define dtg::nexus::fetch ($artifact_name, $artifact_version, $artifact_type, $artifact_classifier, $destination_directory) {
  if $artifact_version =~ /-SNAPSHOT/ {
      $repository = "snapshot"
  }
  else {
      $repository = "release"
  }
  
  if $artifact_classifier =~ /ANY/ {
        $classifier = ""
  }
  else {
        $classifier = "&c=$artifact_classifier"
  }

  $nexus_server_name = "http://dtg-maven.cl.cam.ac.uk/"
  $nexus_user = "dtg"
  $nexus_password = "PetliujyowzaddOn"
  $groupID = "uk.ac.cam.cl.dtg"
  file {$destination_directory:
      ensure => directory
  } ->     
  wget::authfetch { "nexus-fetch":
        source => "\"${nexus_server_name}/service/local/artifact/maven/redirect?r=${repository}&g=${groupid}&a=${artifact_name}&v=${artifact_version}&e=${artifact_type}${classifier}\"",
        destination => "${destination_directory}/${artifact_name}-${artifact_version}.${artifact_type}",
        user => $nexus_user,
        password => $nexus_password
  }
}
