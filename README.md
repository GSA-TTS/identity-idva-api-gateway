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
```

## Development Flow
The development flow for this repo can be split into two streams. Work on the CI/CD pipeline to deploy the application is found under the [pipeline](https://github.com/18F/identity-give-gateway-service/pipeline) while the application code can be done in the [app directory](https://github.com/18F/identity-give-gateway-service/app).

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
