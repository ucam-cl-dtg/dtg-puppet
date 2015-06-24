node /sa497-crunch(-\d+)?/ {
    include 'dtg::minimal'

    class { 'dtg::firewall::hadoopcluster': }

    User<|title == sa497 |> { groups +>[ 'adm' ]}




    $packagelist = [ 'bison' , 'flex', 'autoconf' , 'pkg-config' , 'libglib2.0-dev', 'libpcap-dev' , 'liblz4-tool']
    package {
        $packagelist:
        ensure => installed
    }


}
