node /sa497-crunch(-\d+)?/ {
    include 'dtg::minimal'

    dtg::add_user { 'sa497':
      real_name => 'Sherif Akoush',
      groups    => ['adm'],
      keys      => [],
      uid       => 2412,
    }
}
