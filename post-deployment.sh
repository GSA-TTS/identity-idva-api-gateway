#!/bin/bash
echo 'post deployment script'
cf ssh -N -T -L 8081:localhost:8081 give-api-gateway &
PID=$!
sleep 3
curl -X POST \
    --url "localhost:8081/services" \
    --data "name=auth-service" \
    --data "url=https://konghq.com/"
curl -i -X POST \
    --url http://localhost:8081/services/auth-service/routes \
    --data 'paths[]=/auth' \
    --data 'methods[]=GET&methods[]=POST'
curl -X POST http://localhost:8081/services/auth-service/plugins/ \
    --data "name=oauth2"  \
    --data "config.scopes=rpname" \
    --data "config.mandatory_scope=true" \
    --data "config.enable_client_credentials=true" \
    --data "config.enable_authorization_code=true" \
    --data "config.global_credentials=true" \
    --data "config.accept_http_if_already_terminated=true"
#pytest tests/test_kong.py
kill $PID
