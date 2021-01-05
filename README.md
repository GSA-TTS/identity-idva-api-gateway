<<<<<<< HEAD
# GSA GIVE API Gateway

### Pre-requisites
- [Git Bash](https://git-scm.com/downloads)
- [CF CLI](https://easydynamics.atlassian.net/wiki/spaces/GSATTS/pages/1252032607/Cloud.gov+CF+CLI+Setup)
- [Python 3.9](https://www.python.org/downloads/release/python-390/#:~:text=Files%20%20%20%20Version%20%20%20,%20%208757017%20%206%20more%20rows)
- Cloud.gov account (Contact [Will Shah](mailto:wshah@easydynamics.com?subject=GSA%20Cloud.gov%20Account) to get one).

### Initial Setup

Follow the directions outlined in [Cloud.gov CLI Setup](https://easydynamics.atlassian.net/wiki/spaces/GSATTS/pages/1252032607/Cloud.gov+CF+CLI+Setup)

Setup a database layer for the API Gateway by running:

```
cf create-service aws-rds micro-psql kong-db
```

For more info about database service plans see 
- [Relational databases (RDS)](https://cloud.gov/docs/services/relational-database/)
- [Cloud.gov > Marketplace > Relational databases > Plans](https://dashboard.fr.cloud.gov/marketplace/2oBn9LBurIXUNpfmtZCQTCHnxUM/dcfb1d43-f22c-42d3-962c-7ae04eda24e7/plans)

To setup the API Gateway run:

=======
gateway-service CI/CD App
=================
## Table of Contents
- [Overview](#overview)
- [Installation](#installation)
    - [AWS CDK](#aws-cdk)
    - [Setting Up](#setting-up-your-environment)
- [Development Flow](#development-flow)
    - [Deploying the application](#deploying-the-chalice-application)

## Overview
identity-give-gateway-service is the entry point microservice for the GIVE application and will route all 'public' requests to the appropriate private GIVE microservices. The gateway service itself is an AWS Chalice application. Familiarity with AWS Chalice is a prerequisite for meaningful development in this repo.

## Installation

### AWS CDK
To install the AWS CDK, please follow the [AWS CDK installation instructions](https://docs.aws.amazon.com/cdk/latest/guide/getting_started.html#getting_started_install).

### Setting up your environment
To set up your environment, follow these steps:
```sh
git clone https://github.com/18F/identity-give-gateway-service.git
cd identity-give-gateway-service
python3 -m venv venv38
source venv38/bin/activate
python3 -m pip install -r requirements.txt
pre-commit install
>>>>>>> upstream/main
```

<<<<<<< HEAD
### Continued Deployment

There is no CI/CD in place yet for the continued deployment of the Kong api gateway microservice. To manually deploy, set up a python virtual environment and run:

```
./deploy.sh
```

### Admin API Access

In order to access the Kong Admin API, an SSH tunnel must be set up. Run:

```
cf ssh -N -T -L 8081:localhost:8081 give-api-gateway
```

_8081 is set as the Admin API port in [manifest.yml](manifest.yml), along with 8080 as the proxy port. This is due to Cloud Foundry restricting 8080 as the default port_

=======
## Development Flow
The development flow for this repo can be split into two streams. Work on the CI/CD pipeline to deploy the application is found under the [pipeline](https://github.com/18F/identity-give-gateway-service/pipeline) while the application code can be done in the [app directory](https://github.com/18F/identity-give-gateway-service/app).
>>>>>>> upstream/main

### Deploying the gateway-service application
All deployments require having the correct AWS CLI credentials in place. If you haven't already, install the AWS CLI and set up credentials to your account.
#### With the CI/CD pipeline
Before deploying with the CI/CD pipeline, you must create a CodeStar Connection to the GitHub account your repo is located in. Once that connection is created,
store the ARN of the connection in a SecretsManager Secret, with the JSON key of 'arn'. In JSON, the secret should look like the following:
```json
{ "arn": "<my-connection-arn>" }
```
To deploy the application with the CI/CD pipeline:
```sh
cd pipeline
cdk deploy --parameters ConnectionSecretId=<secret-id>
```
#### Without the pipeline
Deployments without the pipeline must change directories into the hello world directory. Chalice deployments can make direct usage of the `chalice` CLI tool
using `chalice local` or `chalice deploy` commands. Please use `chalice --help` and see the [gateway-service documentation](https://aws.github.io/chalice/index.html).
