#!/bin/bash
echo 'post deployment script'
cf ssh -N -T -L 8081:localhost:8081 give-api-gateway &
PID=$!
sleep 3
curl -X POST http://localhost:8081/plugins/ --data "name=key-auth"
pytest tests/KongTest.py
kill $PID
