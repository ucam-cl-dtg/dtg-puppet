node 'cdn.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  
  class {'apache::ubuntu': } ->
  apache::module {'cgi':} ->
  apache::module {'headers':} ->
  apache::module {'rewrite':} ->
  apache::module {'expires':}
  
  class {'dtg::firewall::publichttp':}
}

