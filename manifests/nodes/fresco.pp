node 'rss39-cadets.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  User<|title == lc525 |> {
    groups +>[ 'adm' ]
  }
  User<|title == rss39 |> {
    groups +>[ 'adm' ]
  }

  ssh_authorized_key {'lc525':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCj2P43qc7yGJz7ErJchupm9/xfowaHlOfNuIveXinF8jvxF1s3szo0KqPGpXeyuKqf0JERTv8o3UGg79R+IESURizs/nvDve4ZEDJbcYt8ywBKqe8T5xkM/41fGTFveJjhMX7c726CqavPbYLlVc7a0cE5RypBYLM2cjyZI5NuJQHQq7fAyl2BTbFrQno6UdQ6xaFffrp04jrJEXjaKSjXP46cVWxtRr50wYH5DbA/XagxPfyaRlayot/axnOWKKHm/EDeRe9zQCJa2L6VaaQDKFw3928xFDz42ZHUQjdioCxsKbT4lw+qvPArJaw7cO/cY53c2VQE5ri9EYVNwLhl',
    type   => 'ssh-rsa',
    user   => 'lc525',
  }

  ssh_authorized_key {'rss39':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAABIwAAAIEAyfPhaw2OA+emyBtpNiyH/Bpl3cvLT5rfaQIPAohpQXVAybpufH/vKFGUOWILBoGtyE08kw3gUL+5tE7wtAr2cfyfnSGrLdvai/khnI4oUxRyEJN61FzmR61Q2ZfxpdzWgjqPl15ISpYcNKnodUVIMor524+3NAR281Cr7999zsk=',
    type   => 'ssh-rsa',
    user   => 'rss39',
  }
}
