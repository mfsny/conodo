# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/tmp/nomad"

bind_addr = "192.168.0.11"

#advertise {
  # We need to specify our host's IP because we can't
  # advertise 0.0.0.0 to other nodes in our cluster.
  #rpc = "192.168.0.11:4647"
#}

# Enable the server
server {
    enabled = true

    #start_join = ["192.168.0.11"]
    #retry_join = ["192.168.0.11"]
    #retry_interval = "15s"

    # Self-elect, should be 3 or 5 for production
    bootstrap_expect = 1
}
