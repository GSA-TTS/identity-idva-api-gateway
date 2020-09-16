#!/bin/bash
cf ssh -N -T -L 8081:localhost:8081 give-api-gateway &
curl -i -X POST http://localhost:8081/services --data name='usps' --data url='https://give-ipp-usps-intelligent-hyena-tl.app.cloud.gov/' & 
kill $!