node /sa497-crunch(-\d+)?/ {
    include 'dtg::minimal'

    User<|title == sa497 |> { groups +>[ 'adm' ]}

    firewall { '001 accept all sa497-crunch-0.dtg.cl.cam.ac.uk':
        action => 'accept',
        source => 'sa497-crunch-0.dtg.cl.cam.ac.uk'
    }

    firewall { '001 accept all sa497-crunch-1.dtg.cl.cam.ac.uk':
        action => 'accept',
        source => 'sa497-crunch-1.dtg.cl.cam.ac.uk'
    }

    firewall { '001 accept all sa497-crunch-2.dtg.cl.cam.ac.uk':
        action => 'accept',
        source => 'sa497-crunch-2.dtg.cl.cam.ac.uk'
    }

    firewall { '001 accept all sa497-crunch-3.dtg.cl.cam.ac.uk':
        action => 'accept',
        source => 'sa497-crunch-3.dtg.cl.cam.ac.uk'
    }

    firewall { '001 accept all vm-sr-nile0.cl.cam.ac.uk':
        action => 'accept',
        source => 'vm-sr-nile0.cl.cam.ac.uk',
    }

    firewall { '001 accept all vm-sr-nile1.cl.cam.ac.uk':
        action => 'accept',
        source => 'vm-sr-nile1.cl.cam.ac.uk',
    }

    firewall { '001 accept all vm-sr-nile2.cl.cam.ac.uk':
        action => 'accept',
        source => 'vm-sr-nile2.cl.cam.ac.uk',
    }

    #not sure why it doesnt accept anya.ad.cl.cam.ac.uk by name
    firewall { '001 accept all 128.232.29.5':
        action => 'accept',
        source => '128.232.29.5',
    }

    firewall { '001 accept all africa01.cl.cam.ac.uk':
        action => 'accept',
        source => 'africa01.cl.cam.ac.uk'
    }

    $packagelist = [ 'bison' , 'flex', 'autoconf' , 'pkg-config' , 'libglib2.0-dev', 'libpcap-dev' , 'liblz4-tool']
    package {
        $packagelist:
        ensure => installed
    }


}
