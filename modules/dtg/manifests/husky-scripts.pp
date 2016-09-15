class dtg::husky-scripts {

    # Setup cl-dtg-make-vm

    class { 'dtg::apt_husky_scripts': stage => 'repos' }

    package {'cl-dtg-make-vm':
        ensure  => latest,
    }

    sudoers::allowed_command{ 'cl-dtg-make-vm':
        command          => '/usr/bin/cl-dtg-make-vm',
        user             => 'ALL',
        run_as           => 'root',
        require_password => false,
        comment          => 'Allow anyone to run cl-dtg-make-vm',
    }

}

class dtg::apt_husky_scripts { # lint:ignore:autoloader_layout repo class
    apt::ppa {'ppa:ucam-cl-dtg/dtg-husky': }
}
