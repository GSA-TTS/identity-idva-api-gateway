#!/bin/bash -e

source ./set_kong_env.sh

# Ensure references to /usr/local resolve correctly
grep -irIl '/usr/local' ../deps/0/apt | xargs sed -i -e "s|/usr/local|$LOCAL|"

# Generate the kong.yaml state file
envsubst < kong-config.yaml > ~/kong.yaml
envsubst < kong.conf.template > ~/kong.conf

# Start the main Kong application.
kong start -c ./kong.conf --v
