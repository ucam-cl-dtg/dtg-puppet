# Overrides of minimal for monitor
class monitor inherits minimal {
  # monitor needs to be able to monitor itself via localhost
  Class['munin::node'] { node_allow_ips +> ['^127\.0\.0\.1$'] }
}
