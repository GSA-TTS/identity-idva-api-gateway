#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 dev|test|prod"
fi

if [[ $1 == "dev" ]]; then
    deck_file=kong-dev.yaml
elif [[ $1 == "test" ]]; then
    deck_file=kong-test.yaml
elif [[ $1 == "prod" ]]; then
    deck_file=kong-prod.yaml
else
    echo "Usage: $0 dev|test|prod"
    exit 1
fi

echo "Kong state file - $deck_file"
export KONG_DECLARATIVE_CONFIG="$deck_file"

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

# Start the main Kong application.
kong start -c kong.conf --v

# Keep this shell process alive. If it exits, it will cause cloudfoundry to try to restart the instance.
while true; do
  sleep 10
  if ! pgrep --full "nginx: master process" > /dev/null; then
    echo "Main Nginx process crashed"
    exit 1
  fi
done
