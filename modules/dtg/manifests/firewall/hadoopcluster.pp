# hadoop related nodes, probably should do the required ports only (for yarn)
class dtg::firewall::hadoopcluster inherits dtg::firewall::default {

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

    firewall { '001 accept all africa01.cl.cam.ac.uk':
        action => 'accept',
        source => 'africa01.cl.cam.ac.uk',
    }
}
