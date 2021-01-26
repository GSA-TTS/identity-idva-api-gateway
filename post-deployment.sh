#!/bin/bash

# Post Deployment Kong API Gateway Setup
# Deploys plugins, services, and routes
# Runs unit tests 

# setup ssh tunnel to Kong Admin API
cf ssh -N -T -L 8081:localhost:8081 give-api-gateway &
PID=$!
sleep 3

# add auth service
curl -X POST \
    --url "localhost:8081/services" \
    --data "name=auth-service" \
    --data "url=https://konghq.com/"

# add routes to auth service
curl -i -X POST \
    --url http://localhost:8081/services/auth-service/routes \
    --data 'paths[]=/auth' \
    --data 'methods[]=GET&methods[]=POST'

# add oauth plugin to service
curl -X POST http://localhost:8081/services/auth-service/plugins/ \
    --data "name=oauth2"  \
    --data "config.scopes=rpname" \
    --data "config.mandatory_scope=true" \
    --data "config.enable_client_credentials=true" \
    --data "config.enable_authorization_code=true" \
    --data "config.global_credentials=true" \
    --data "config.accept_http_if_already_terminated=true"

# add global oauth plugin
curl -X POST http://localhost:8081/plugins/ \
    --data "name=oauth2"  \
    --data "config.scopes=rpname" \
    --data "config.mandatory_scope=true" \
    --data "config.enable_authorization_code=true" \
    --data "config.enable_client_credentials=true" \
    --data "config.global_credentials=true" \
    --data "config.accept_http_if_already_terminated=true"


# add idemia service
curl -X POST \
    --url "localhost:8081/services" \
    --data "name=idemia-microservice" \
    --data "url=http://ipp-idemia-busy-eland-mg.app.cloud.gov/"

# add GET route to idemia service
curl -i -X POST \
    --url http://localhost:8081/services/idemia-microservice/routes \
    --data 'paths[]=/ipp' \
    --data 'methods[]=GET'

# run unit tests
pytest tests/test_kong.py
kill $PID
