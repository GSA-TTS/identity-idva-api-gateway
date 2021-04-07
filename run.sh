#!/bin/bash
set -e

if [ -z $1 ]; then
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

# Make location of libs configurable
LOCAL='/home/vcap/deps/0/apt/usr/local'

export LD_LIBRARY_PATH=$LOCAL/lib:$LOCAL/lib/lua/5.1/:$LOCAL/openresty/luajit/lib:$LOCAL/openresty/pcre/lib:$LOCAL/openresty/openssl111/lib:$LD_LIBRARY_PATH
export LUA_PATH="$LOCAL/share/lua/5.1/?.lua;$LOCAL/share/lua/5.1/?/init.lua;$LOCAL/openresty/lualib/?.lua"
export LUA_CPATH="$LOCAL/lib/lua/5.1/?.so"
export PATH=$LOCAL/bin/:$LOCAL/openresty/nginx/sbin:$LOCAL/openresty/bin:$PATH

# Ensure references to /usr/local resolve correctly
grep -irIl '/usr/local' ../deps/0/apt | xargs sed -i -e "s|/usr/local|$LOCAL|"

SERVICE=aws-rds
export KONG_PG_USER=`echo $VCAP_SERVICES | jq -r '.["'$SERVICE'"][0].credentials.username'`
export KONG_PG_PASSWORD=`echo $VCAP_SERVICES | jq -r '.["'$SERVICE'"][0].credentials.password'`
export KONG_PG_HOST=`echo $VCAP_SERVICES | jq -r '.["'$SERVICE'"][0].credentials.host'`
export KONG_PG_PORT=`echo $VCAP_SERVICES | jq -r '.["'$SERVICE'"][0].credentials.port'`
export KONG_PG_DATABASE=`echo $VCAP_SERVICES | jq -r '.["'$SERVICE'"][0].credentials.db_name'`
export KONG_LUA_PACKAGE_PATH=$LUA_PATH
export KONG_LUA_PACKAGE_CPATH=$LUA_CPATH

# Run bootstrap/migration commands that should only be run by one Kong node
if [[ $CF_INSTANCE_INDEX -eq 0 ]]; then
    # Bootstrap the kong database and runs migrations. If the database is already bootstrapped, does nothing.
    kong migrations bootstrap
fi

# Start the main Kong application.
kong start -c kong.conf --v

# Perform configuration sync (only one Kong node should run this)
if [[ $CF_INSTANCE_INDEX -eq 0 ]]; then
    # Only install deck if it's not already installed. Prevents re-downloading binary on application restarts.
    if [ ! -f "./deck" ]; then
        echo "Starting decK install"
        curl --silent --location https://github.com/kong/deck/releases/download/v1.3.0/deck_1.3.0_linux_amd64.tar.gz --output deck.tar.gz
        tar --extract --file=deck.tar.gz
        echo "Deck install complete. Deck version $(./deck version)"
    fi

    KONG_ADDR="http://localhost:8081"

    # Ensure we can connect to the kong instance
    ./deck ping --kong-addr $KONG_ADDR

    # Run a diff to log what changes are being made
    ./deck diff --kong-addr $KONG_ADDR --skip-consumers --state $deck_file

    # Synchronize changes
    ./deck sync --kong-addr $KONG_ADDR --skip-consumers --state $deck_file
fi

# Keep this shell process alive. If it exits, it will cause cloudfoundry to try to restart the instance.
while true;do
	sleep 10
	nginx_count=`ps aux | grep maste[r] | wc -l`
	if [ "$nginx_count" != "1" ];then
		echo "Some process crashed"
		ps aux
		exit 1
	fi
done
