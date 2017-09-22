# VM for jz448 APK analysis project
node 'jz448-apkanalysis.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  User<|title == jz448 |> { groups +>[ 'adm' ] }
}