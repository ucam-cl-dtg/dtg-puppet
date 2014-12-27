node /sa497-crunch(-\d+)?/ {
    include 'dtg::minimal'

  User<|title == sa497 |> { groups +>[ 'adm' ]}

  
}
