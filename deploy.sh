#!/bin/bash

# Pseudo deployment executable
# Deploys app to cloud.gov with cloud foundry 

# dependency phase
python3.9 -m pip install -r tests/requirements.txt

# deployment phase
cf push --vars-file vars.yml

# post reployment phase
./post-deployment.sh
