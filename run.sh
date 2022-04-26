#!/bin/bash
set -e

# Make location of libs configurable
LOCAL='/home/vcap/deps/0/apt/usr/local'

export LD_LIBRARY_PATH=$LOCAL/lib:$LOCAL/lib/lua/5.1/:$LOCAL/openresty/luajit/lib:$LOCAL/openresty/pcre/lib:$LOCAL/openresty/openssl111/lib:$LD_LIBRARY_PATH
export LUA_PATH="$LOCAL/share/lua/5.1/?.lua;$LOCAL/share/lua/5.1/?/init.lua;$LOCAL/openresty/lualib/?.lua"
export LUA_CPATH="$LOCAL/lib/lua/5.1/?.so;$LOCAL/openresty/lualib/?.so"
export PATH=$LOCAL/bin/:$LOCAL/openresty/nginx/sbin:$LOCAL/openresty/bin:$PATH

# Ensure references to /usr/local resolve correctly
grep -irIl '/usr/local' ../deps/0/apt | xargs sed -i -e "s|/usr/local|$LOCAL|"

export KONG_LUA_PACKAGE_PATH=$LUA_PATH
export KONG_LUA_PACKAGE_CPATH=$LUA_CPATH

# Generate the kong.yaml state file
/home/vcap/deps/0/apt/usr/bin/envsubst < kong-config.yaml > /home/vcap/app/kong.yaml
/home/vcap/deps/0/apt/usr/bin/envsubst < kong.conf.template > /home/vcap/app/kong.conf

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
