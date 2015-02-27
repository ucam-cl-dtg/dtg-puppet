define bayncore_ssh_user($real_name,$uid) {
  $username = $title
  user { $username:
    ensure     => present,
    comment    => "${real_name} <${email}>",
    home       => "/home/${username}",
    shell      => '/bin/bash',
    groups     => [],
    uid        => $uid,
    membership => 'minimum',
    password   => '*',
  }
  ->
  group { $username:
    require => User[$username],
    gid     => $uid,
  }
  ->
  file { "/home/${username}/":
    ensure  => directory,
    owner   => $username,
    group   => $username,
    mode    => '0755',
  }
  ->
  file {"/home/${username}/.ssh/":
    ensure => directory,
    owner => $username,
    group => $username,
    mode => '0700',
  }
  ->
  exec {"gen-${username}-sshkey":
    command => "sudo -H -u ${username} -g ${username} ssh-keygen -q -N '' -t rsa -f /home/${username}/.ssh/id_rsa",
    creates => "/home/${username}/.ssh/id_rsa",
  }
  ->
  file {"/home/${username}/.ssh/authorized_keys":
    ensure => present,
    owner => $username,
    group => $username,
    mode => '0600',
  }
  ->
  exec {"${username}-add-authkey":
    command => "/bin/cat /home/${username}/.ssh/id_rsa.pub >> /home/${username}/.ssh/authorized_keys",
    unless => "/bin/grep \"`/bin/cat /home/${username}/.ssh/id_rsa.pub`\" /home/${username}/.ssh/authorized_keys",
    user => $username,
    group => $username,
  }
}

define bayncore_setup() {

  exec { "remount":
    command => "/bin/mount -a",
    refreshonly => true,
  }

  package {["gfortran"]:
    ensure => installed,
  }
  
  file {'/mnt/bayncore':
    ensure => directory,
  }
  ->
  file_line { 'mount nas04':
    line   => 'nas04.dtg.cl.cam.ac.uk:/dtg-pool0/bayncore /mnt/bayncore nfs defaults 0 0',
    path   => '/etc/fstab',
    ensure => present,
    notify => Exec["remount"],
  }

  bayncore_ssh_user {'rogerphilp':
    real_name => "Roger Philp (Bayncore)",
    uid       => 20000
  }
  ->
  ssh_authorized_key {'rogerphilp key 1':
    ensure => present,
    key    => "AAAAB3NzaC1yc2EAAAADAQABAAABAQCTFKOWLHlRRflNsNNWinPuH44Ptsh6x5PBGo7NQkmdUJlZ45CkIZcJ/ObP2+HPFmXuBynTesOmZPuGFokuKJ+ZwVN8ZgHMZlmS+cdVedRgQkZJdlFHcscYa0rDkDShh70k+4zT6QJRC+haX/ZcQ1SkVmpBlr9BzMGMJdORKKgOPVvrd9F5c0Tp9px7SPRsIpR3WTeKztpxjTXpmCHl5toYigMrhzWerpti44z6riX5LOGVb/RRuEAxQb6k5RRvs90WqOAMpakgod64uV89xlO0B0tHAGUynZS3CZkL0/jKLkecA3BnyAHpKkVTje7JptEJPOmoYbKqJjgsGrsZS9zZ",
    user   => 'rogerphilp',
    type   => 'ssh-rsa',
    name   => 'scornp@linux.site',
  }
  ->
  ssh_authorized_key {'rogerphilp key 2':
    ensure => present,
    key    => "AAAAB3NzaC1yc2EAAAADAQABAAABAQDZe3VhWrRwdiboJPZBlwWyGWDPhf/emu/NhY0OkPbbZJej7qAsXBcePkiUCKFyrRfOyYq2soS1+uKNOIDqFj8yL/6sqHzuL2Swrglsg73eS/Gs5HevPFZxfkuAxnRnW+y5YScEtYdbonpzuBHUlKYPUVyEwgdr1Vtx7vS9HhmbBGLXedQKoLYJtu2KrzUpPqzOFWH9h/elr13z7sQ8iAcZrxPAul1cL0UZY62GJpAcelxs+PFMCi40BQToyDs+fkqEEdcCxR8R2Whr221YbBorwIX0VrwPnF2lk/8+WNrklR5MZNDqd/bAzwQtuEBFqEevmSwsYpZvFIYZ6Qavssc9",
    user   => 'rogerphilp',
    type   => 'ssh-rsa',
    name   => 'scornp@admins-MacBook-Pro.local',
  }
  ->
  ssh_authorized_key {'rogerphilp key 3':
    ensure => present,
    key    => "AAAAB3NzaC1yc2EAAAADAQABAAABAQCtwKeYbkU/WoCSC1CLqgaoU1nlqS9Q3PhEV1576bOWwduWZd38rTJYOqKYpZJoJ8CjFp7pe2gF7PUmbFelqSbm/K4+zUyh4jKeHi4YPq9KzGHMGRIMCZdb5hDGd2CWyYfcMYMzZhk1ntSS70Kl0w9p0HXXeokxLamm6Kxv8KBEsFVB4oIMBDhEpvNmqyV0VeGYGO18VsR5k4QvV8DdW4nScr5kgMfW2hL2j1ihSs+umB0FQVv5ceaZzisiQIzhCkPgb2Q/oG/UmF8jSb1KAPtFHs+pL/AfZLp/2+SiTlL5hFPJDTmHJY/N8mR2bXSEuB4W2AwF1R13MEAdRH8GvpS9",
    user   => 'rogerphilp',
    type   => 'ssh-rsa',
    name   => 'roger@PurpleMonkey-Mint',
  }
  ->
  ssh_authorized_key {'rogerphilp key 4':
    ensure => present,
    key    => "AAAAB3NzaC1yc2EAAAABJQAAAQEAsJp1ORRaLLNEk++ZmPFOoP0BktKlOgfMPfLq6KPhFUXUcQpFIY+WDh2RyRYbHB62eyKtj7dgtJn0zmM1PCen1CMENEKraky+lMsvOTOENGuVErmLyed6TMoBZbAXl7FgLXjMxZrccQELmwt13Mx0R7D7rYlh35YaXlQ6HGgVZ0jHyewKQATVW8Qx/SpFwGwKFywRswxawm/0JwVjU4uyrkTFIIg02coEHdT3g/M91XMjxn8gKShfBuHeiZghNC+z8Cx4cgfprIxTSJqgu1th92B5GHTz1aEAoDYO86pmEGU9YCxcXc5yCLTCtSGE8MHfmp+FVVJ1CDPLScxdqqESmw==",
    user   => 'rogerphilp',
    type   => 'ssh-rsa',
    name   => 'rsa-key-20150210',
  }

  bayncore_ssh_user {'manelfernandez':
    real_name => "Manel Fernandez (Bayncore)",
    uid       => 20001,
  }
  ->
  ssh_authorized_key {'manelfernandez key 1':
    ensure => present,
    key    => "AAAAB3NzaC1yc2EAAAABJQAAAQEAljBk6Yym5tC/qFghpVg+IFzRAaFAbVYY1CdBJ4lGYxFYwpPVcTWrvjK/k4FhsqCQ9bWO2qKo21SgxkhdpJAVCxi9+uOnatOt+wm7/s43RjrF4LArMAoE2F+wWXjy6G7xK94llZR5DxcZ+zgbi/X5a+9uruB8y/zAgRZYsLMGGspwr0MjO2EeFK01LrfdIaXj/skz/Kxy7IWmtzGmpuTHXNoDMXE02+cowVtHZRNosrdIWNM5Isw/SwPeVjG8X2ydLVVcXIJFev5J9yb7JbKlTrnhK/55++lZbKmOSnBWcRmLiHj8PlUFueGNSMbQYtCHlxIa1beNIT+Iyscc1zsTAQ==",
    user   => 'manelfernandez',
    type   => 'ssh-rsa',
    name   => 'bayncore-rsa2-key-20150212',
  }
  ->
  ssh_authorized_key {'manelfernandez key 2':
    ensure => present,
    key    => "AAAAB3NzaC1yc2EAAAABJQAAAQEAgxAUIRKP4c8AgzadUbhlrgg0pWH031vVLNjQ5ewL8bzLhv6eSqh4grE15KzYVxGjKszi8m3UPYzwOTN4tOVOWACfLawkuzjZBTB6ecX7Ygw+YSZA8I1OZZAItVC0c9Xom9v6muOeNUo/WdcBbs/u5xaMQacdV0rMflzAN5CxKnIVQPOCn+JVXoAETnVqrIFi2P9f+6/oh9T8bg3zSVQXqiy3xUu8scrKMHbAxQJZWD6LCZP1HdSv7rtRs9BoPfqBrci7Q30sL3FWR+yjeDVe5XhZSlgawjE9o0xIMQEePJm/QpIFGhpP5NebEvmrtUqQbxrgcYu8p2Z6HFOjoPNPPQ==",
    user   => 'manelfernandez',
    type   => 'ssh-rsa',
    name   => 'rsa-key-hartree',
  }
  ->
  ssh_authorized_key {'manelfernandez key 3':
    ensure => present,
    key    => "AAAAB3NzaC1yc2EAAAADAQABAAABAQC/wadZNjmYVVbwPawYqFi7Gi+zlmfweu2eH+mNc/OWDzFKTGCRBz4JV8groKvHBSuWeciXvXxDLGldGdmHwcb1m1cSlxJX4n0RVkefB0CPSKHGGsTBZHFijQ7bHe5XFg94JB9Tiq0diqXYRL9ARjR401UvRTWoAKzGpoOfzhKqogeK5q9nfbzvERHb8iVFYdGQ5Ck4a+4JTQlKYtEhx0moqmCHgOIeA8khnOgL0hhLJQtr5UoHvTgY7DGhPw0R/x1y3VQnIqEa6k9+uLvwKIaFDB8tRwbQSCVDS12K9zUlDgMeCbWAVvavOVB+nmcFXVI83iKV2ZPtVHBufyYe7RMR",
    user   => 'manelfernandez',
    type   => 'ssh-rsa',
    name   => 'manel@manel-ubuntu',
  }

  bayncore_ssh_user {'richardpaul':
    real_name => "Richard Paul (Bayncore)",
    uid       => 20002
  }
  ->
  ssh_authorized_key {'richardpaul key 1':
    ensure => present,
    key    => "AAAAB3NzaC1yc2EAAAABJQAAAIEAp3Le2fGXZ2Id15pDoeVUrzkpwEDsbJXzi4m1GkXttlhOy39LZr1WgMAe8SKXJ6iC4kETlTjDd9giLO/nf7kEtqJQ/aMbo4VtJZL2E5PaAU6eH7NumnAi1P/mjRU990Ng2wMi2Heccy0Y7W0VjQ9hatj6v6S1GF8gc/FZeG3d1qc=",
    user   => 'richardpaul',
    type   => 'ssh-rsa',
    name   => 'rsa-key-20150220',
  }
            
}

node /saluki(\d+)?/ {
  include 'dtg::minimal'

  include 'nfs::server'

  $packages = ['build-essential','linux-headers-generic','alien','libstdc++6:i386','vnc4server']

  package{$packages:
    ensure => installed,
  }
  
  firewall { '050 accept all 172.31.0.0/16':
    action => 'accept',
    source => '172.31.0.0/16'
  }

  firewall { '051 nat 172.31.0.0/16':
    chain    => 'POSTROUTING',
    jump     => 'MASQUERADE',
    proto    => 'all',
    outiface => "eth0",
    source   => '172.31.0.0/16',
    table    => 'nat',
  }

  exec { "ipforward":
    command => "/bin/echo 1 > /proc/sys/net/ipv4/ip_forward",
    unless => "/bin/grep 1 /proc/sys/net/ipv4/ip_forward",
  }

  augeas { "sysctl-ipforward":
    context => "/files/etc/sysctl.conf",
    changes => [
                "set net.ipv4.ip_forward 1"
                ],
  }
    
  
  bayncore_setup { 'saluki-users': }
  ->
  nfs::export{["/home"]:
    export => {
      "172.31.0.0/16" => "rw,no_subtree_check,insecure,no_root_squash",
    },
  }
}

node /naps-bayncore/ {
  include 'dtg::minimal'

  $packages = ['build-essential','libstdc++6:i386','vnc4server']
  
  bayncore_setup { 'naps-bayncore': }

  package{$packages:
    ensure => installed,
  }
  
}

if ( $::monitor ) {
  munin::gatherer::configure_node { 'saluki1': }
  munin::gatherer::configure_node { 'saluki2': }
}
