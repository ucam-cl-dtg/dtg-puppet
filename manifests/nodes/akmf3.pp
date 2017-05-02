# VM for akmf3 bigdata analytics project


node /bda(-\d+)?/ {
  include 'dtg::minimal'

  dtg::sudoers_group{'neat':
    group_name => 'neat',
  }
}

