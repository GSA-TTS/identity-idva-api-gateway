#!/bin/bash

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
export KONG_LUA_PACKAGE_PATH=$LUA_PATH
export KONG_LUA_PACKAGE_CPATH=$LUA_CPATH

# Start kong
kong migrations bootstrap
kong start --vv

# Keep this process alive
while true;do
	sleep 10
	nginx_count=`ps aux | grep maste[r] | wc -l`
	if [ "$nginx_count" != "1" ];then
		echo "Some process crashed"
		ps aux
		exit 1
	fi
done