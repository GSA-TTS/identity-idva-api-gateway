#!/bin/bash
echo 'post deployment script'
cf ssh -N -T -L 80:localhost:8081 give-api-gateway &
curl -X POST http://localhost:80/plugins/ --data "name=hmac-auth" -d "config.enforce_headers=date, request-line" &
pytest tests/KongTest.py &
kill $!
