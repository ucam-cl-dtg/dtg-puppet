
node /^nn256.*\.dtg\.cl\.cam\.ac\.uk$/ {
  include 'dtg::minimal'
  dtg::add_user{ 'nn256':
    real_name => 'Nicholas Ngorok',
    groups    => [ 'adm' ],
  }
  ssh_authorized_key {'nn256':
    ensure => present,
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDQS4iz4Xsp3TPSH2lvsyV2781rc4Nr8YkJLVWV/DvH0VmVVqRHDPTa2ikRz+DwvDAt9vliWgew5Sspmq/Nae7vQqH7nRQdUDEBkuIysYoe4hSVorHB34k1IwwCQqlSt3tfLtPoVJRcVIs4geYJzfhxwVzOLNX5zuZaGWZfPIT55MqrxJMQP+fnRZPnLFYWHzk2Su2kiMHOl+clo6m5UM+DjA5ztWfLsJz4fhzGg/yWjtZElzxZ9Tyc0hOgxkjBkv2WS3RL/Yn8at4qcYRp7YMtcniba/qkAqO6c27kvf1/3ik0e0eC+xqj7akOFhYs20n+/Jk74hRccP2BKK+a2bMf',
    user => 'nn256',
  }
}
