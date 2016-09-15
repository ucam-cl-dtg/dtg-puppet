# hadoop related nodes, probably should do the required ports only (for yarn)
class dtg::firewall::hadoopcluster inherits dtg::firewall::default {

    firewall { '001 accept all sa497-crunch-0.dtg.cl.cam.ac.uk':
        action => 'accept',
        source => 'sa497-crunch-0.dtg.cl.cam.ac.uk',
    }

    firewall { '001 accept all sa497-crunch-1.dtg.cl.cam.ac.uk':
        action => 'accept',
        source => 'sa497-crunch-1.dtg.cl.cam.ac.uk',
    }

    firewall { '001 accept all sa497-crunch-2.dtg.cl.cam.ac.uk':
        action => 'accept',
        source => 'sa497-crunch-2.dtg.cl.cam.ac.uk',
    }

    firewall { '001 accept all sa497-crunch-3.dtg.cl.cam.ac.uk':
        action => 'accept',
        source => 'sa497-crunch-3.dtg.cl.cam.ac.uk',
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
        source => 'africa01.cl.cam.ac.uk',
    }

    firewall { '001 accept all sa497mac.mac.cl.cam.ac.uk':
        action => 'accept',
        source => 'sa497mac.mac.cl.cam.ac.uk',
    }

    firewall { '001 accept all airwolf.cl.cam.ac.uk':
        action => 'accept',
        source => 'airwolf.cl.cam.ac.uk',
    }

}
