node 'isaac-statistics.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  class {'dtg::isaac':}

  dtg::add_user { 'ajb300':
    real_name => 'Alex Bate',
    groups    => [ 'adm' ],
    keys      => '',
    uid       => 3253,
  } ->
  ssh_authorized_key {'ajb300_key':
    ensure => present,
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQC9p4icNQO9Ocj0UOKkP1IPR5/yQbzU7SKKU9t7Zjb0GTW0R2cI2TqF13PKcrwkMDQLcN1Do5ar89jVzPmZ+kTGlhZjVF3YTaHQt9f/JBeRRCdrLFO4/3WzUiZcp1tvedn7fd0EO5oRV1BQ7jCh27dFfspsPApD9Gje1RcF0yznZf4YqdvDPvDoSmgG6zONvZc2RVXSNqTcWSVo/sEEoxeraKuZY+zu6xvqpi7BeaZMK38cGUe2xkzs9BQOjxdqtEZDTTiRD6tBDcfZ4F+7ymadJ+QbUoD2tIAtCaES84Fqk6cgAtvckLkKqe1WUmb1Ty/UTA0+P9n76dwSLVD4WSLwIhv1JcdD4xfC6eD58pm2P4Oxh4KXQZxsdOwAFflfppJQVe1DzUDbh2BoMcpjJ4Y6KCCvzcdHdrkuMVU8Djb0oksi521xDysdXPasa5Kf/4JMBN8q9ljdeVI8juyjeXgFfYpe9RCOO2UyeDzqe1iRgezNc5fvh+csAXyzI2gIF35OQQxaZncFNRk68Ctp/Bs4tVst6FBm+Wwqo2C9fUyiCrqQR1feffg1kxDM5kia00Nb6q8psHIgKvd56KTgxwEhJcuPmpsi0XcmN8xS5+X7uo834GA5bRmOl2VEbScv2zln8Ygoe5IfVoi0CsoiGpxNnNAGeC1eHAwHjbyEvhS2Ow==',
    user   => 'ajb300',
    type   => 'ssh-rsa',
  }
  
  class {'dtg::firewall::publichttp':}

  class {'apache::ubuntu': }
}