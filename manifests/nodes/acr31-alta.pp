node 'acr31-alta.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  User<|title == rjm49 |> {
    groups +>[ 'adm' ]
  }

}
