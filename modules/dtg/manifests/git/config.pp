class dtg::git::config {
  exec{'git graph':
    command => 'git config --system --add alias.graph \'log --graph --date-order -C -M --pretty=format:"<%h> %ad [%an] %Cgreen%d%Creset %s" --all --date=short\'',
    unless  => 'git config --get alias.graph',
  }
  exec{'git transfer.fsckObjects':
    command => 'git config --system --bool --add transfer.fsckObjects true',
    unless  => 'git config --get transfer.fsckObjects',
  }
  dtg::git::config::user{'root':
    real_name => 'DTG Infrastructure',
    email     => 'dtg-infra@cl.cam.ac.uk',
  }
}
