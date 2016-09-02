# Install ruby and passenger before gollum
class dtg::git::gollum::pre {
    include rvm
    #rvm::system_user{ lc525: }

    rvm_system_ruby{'ruby-1.9.3-p194':
      ensure => present,
      default_use => true;
    }

    rvm_gemset{'ruby-1.9.3-p194@gollum':
      ensure => present,
      require => Rvm_system_ruby['ruby-1.9.3-p194'];
    }

    class{
      'rvm::passenger::apache':
      version => '3.0.18',
      ruby_version => 'ruby-1.9.3-p194',
      mininstances => '3',
      maxinstancesperapp => '0',
      maxpoolsize => '30',
      spawnmethod => 'smart-lv2';
    }
}
