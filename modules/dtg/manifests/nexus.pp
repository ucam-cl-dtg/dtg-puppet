define dtg::nexus::fetch (
       $artifact_name, 
       $artifact_version, 
       $artifact_type,
       $artifact_classifier = "ANY", 
       $destination_directory,
       $nexus_server_name = "http://dtg-maven.cl.cam.ac.uk",
       $nexus_user = "dtg",
       $nexus_password = "PetliujyowzaddOn",
       $groupID = "uk.ac.cam.cl.dtg",
       $action = "NONE"
       ) {

  $destination_file = "${artifact_name}-${artifact_version}.${artifact_type}"
  $destination_path = "${destination_directory}/${destination_file}"

  if $artifact_version =~ /-SNAPSHOT/ { $repository = "snapshot" } else { $repository = "releases" }
  if $artifact_classifier == "ANY" { $classifier = "" } else { $classifier = "&c=$artifact_classifier" }

  file {$destination_directory: ensure => directory } ->
  wget::authfetch { "nexus-fetch-$destination_file":
        source => "\"${nexus_server_name}/service/local/artifact/maven/redirect?r=${repository}&g=${groupID}&a=${artifact_name}&v=${artifact_version}&e=${artifact_type}${classifier}\"",
        destination => $destination_path,
        user => $nexus_user,
        password => $nexus_password,
  } 

  if $action == "unzip" {
     if !defined(Package['unzip']) {
          package{'unzip':
	  	   name => 'unzip',
	  	   ensure => installed,      
	  }		   
     }


     exec { "unzip ${destination_path}":
     	  require => Package['unzip'],
      	  cwd => $destination_directory,
      	  creates => "${destination_directory}/${artifact_name}-${artifact_version}/",
	  path => ["/usr/bin"]
    }
   }
}
       
