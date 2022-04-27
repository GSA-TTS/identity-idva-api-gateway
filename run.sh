#!/bin/bash -e

source ./set_kong_env.sh

# Generate the kong.yaml state file
envsubst < kong-config.yaml > ~/kong.yaml
envsubst < kong.conf.template > ~/kong.conf

# Start the main Kong application.
kong start -c ./kong.conf --v
