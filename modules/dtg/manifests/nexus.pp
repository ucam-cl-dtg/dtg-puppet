define dtg::nexus::fetch (
  $artifact_name,                                           # the name of the artifact to download from nexus
  $artifact_version,                                        # its version number
  $artifact_type,                                           # the type: war, zip, jar etc.
  $artifact_classifier = 'ANY',                             # classifier e.g. live or leave as ANY (default)
  $destination_directory,                                   # the directory to store the downloaded file in
  $nexus_server_name = 'http://maven.dtg.cl.cam.ac.uk',     # nexus server host name (include http, ommit trailing slash)
  $nexus_user = 'dtg',                                      # username for nexus server
  $nexus_password = 'PetliujyowzaddOn',                     # password for nexus server
  $groupID = 'uk.ac.cam.cl.dtg',                            # maven group id for artifact
  $action = 'NONE',                                         # unzip => archive file should be unzipped, NONE (default) => do nothing
  $symlink = 'NONE',                                        # file and path => symlink the downloaded file to here, NONE (default) => do nothing
  $always_refresh = false                                   # set this to true to force the download to go ahead whether the file is already there or not
  ) {
  
  $destination_filename = "${artifact_name}-${artifact_version}.${artifact_type}"
  $destination_path = "${destination_directory}/${destination_filename}"
  
  if $artifact_version =~ /-SNAPSHOT/ { $repository = 'snapshots' } else { $repository = 'releases' }
  if $artifact_classifier == 'ANY' { $classifier = '' } else { $classifier = "&c=${artifact_classifier}" }
  
  file {$destination_directory: ensure => directory } ->
  wget::fetch { "nexus-fetch-${destination_filename}":
    source      => "${nexus_server_name}/service/local/artifact/maven/redirect?r=${repository}&g=${groupID}&a=${artifact_name}&v=${artifact_version}&e=${artifact_type}${classifier}",
    destination => $destination_path,
    user        => $nexus_user,
    password    => $nexus_password,
    redownload  => $always_refresh
  }

  if $action == 'NONE' {
    if $symlink != 'NONE' {
      file{ $symlink:
        require => Wget::Fetch["nexus-fetch-${destination_filename}"],
        ensure  => link,
        target  => $destination_path,
      }
    }
  }
  elsif $action == 'unzip' {
    $unzip_target = "${destination_directory}/${artifact_name}-${artifact_version}/"
    
    if !defined(Package['unzip']) {
      package{'unzip':
  name   => 'unzip',
  ensure => installed,
      }
    }

    # We do execute the unzip command whenever the mtime of the zip
    # file is newer than the mtime of the target directory.  This
    # means that if we've forced wget to download a new copy of the
    # file then unzip will run automatically
    exec { "unzip-${destination_filename}":
      command => "unzip -o ${destination_path}",
      require => [ Package['unzip'], Wget::Fetch["nexus-fetch-${destination_filename}"] ],
      cwd     => $destination_directory,
      onlyif  => "test ${destination_path} -nt ${unzip_target}",
      path    => ['/usr/bin']
    }
    
    if $symlink != 'NONE' {
      file{ $symlink:
        require => Exec["unzip-${destination_filename}"],
        ensure  => link,
        target  => $unzip_target,
      }
    }
  }
  else {
    err('Unrecognised action')
  }
}
       
