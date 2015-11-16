define dtg::sudoers_group($group_name) {

    sudoers::allowed_command{ $group_name:
      command          => 'ALL',
      group            => $group_name,
      run_as           => 'ALL',
      require_password => false,
      comment          => $group_name,
      require          =>  [ Group["${group_name}"], ],
  }

}
