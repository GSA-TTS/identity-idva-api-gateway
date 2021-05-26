#!/bin/bash
set -e

# Make location of libs configurable
LOCAL='/home/vcap/deps/0/apt/usr/local'

export LD_LIBRARY_PATH=$LOCAL/lib:$LOCAL/lib/lua/5.1/:$LOCAL/openresty/luajit/lib:$LOCAL/openresty/pcre/lib:$LOCAL/openresty/openssl111/lib:$LD_LIBRARY_PATH
export LUA_PATH="$LOCAL/share/lua/5.1/?.lua;$LOCAL/share/lua/5.1/?/init.lua;$LOCAL/openresty/lualib/?.lua"
export LUA_CPATH="$LOCAL/lib/lua/5.1/?.so"
export PATH=$LOCAL/bin/:$LOCAL/openresty/nginx/sbin:$LOCAL/openresty/bin:$PATH

# Ensure references to /usr/local resolve correctly
grep -irIl '/usr/local' ../deps/0/apt | xargs sed -i -e "s|/usr/local|$LOCAL|"

export KONG_LUA_PACKAGE_PATH=$LUA_PATH
export KONG_LUA_PACKAGE_CPATH=$LUA_CPATH

# Generate the kong.yaml state file
/home/vcap/deps/0/apt/usr/bin/envsubst < kong-config.yaml > /home/vcap/app/kong.yaml

# Start the main Kong application.
kong start -c ./kong.conf --v

# Keep this shell process alive. If it exits, it will cause cloudfoundry to try to restart the instance.
while kong health > /dev/null; do
  sleep 10
done

exit 1
