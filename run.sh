#!/bin/bash -e

source ./set_kong_env.sh

# Generate the kong.yaml state file
envsubst < kong-config.yaml > ~/kong.yaml
envsubst < kong.conf.template > ~/kong.conf

instance_identity_cert_folder=$(dirname "$CF_INSTANCE_CERT")

# An infinite-loop function that will watch the cf instance identity certs for changes
# and tell kong to reload its configuration if the files are updated.
instance_identity_cert_watcher() {
  while inotifywait -q -e modify "$instance_identity_cert_folder" ; do 
    kong reload -c ./kong.conf --v
  done
}

instance_identity_cert_watcher &

# Start the main Kong application.
kong start -c ./kong.conf --v
