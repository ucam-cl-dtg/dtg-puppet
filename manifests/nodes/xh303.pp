# VM for xh303 security analysis work


node /xh303-ids/ {
  include 'dtg::minimal'

  User<|title == xh303 |> { groups +>[ 'adm' ] }
}

