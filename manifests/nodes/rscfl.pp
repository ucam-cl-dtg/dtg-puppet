node /.*rscfl.*/ {
  include 'dtg::minimal'

  class { 'dtg::rscfl': }
}
