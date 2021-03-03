[![Maintainability](https://api.codeclimate.com/v1/badges/51007637d64a020ca966/maintainability)](https://codeclimate.com/github/18F/identity-give-gateway-service/maintainability)
![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)

# GIVE API Gateway
The Government Identity Verification Engine (GIVE) API gateway uses
[Kong Gateway (OSS)](https://docs.konghq.com/gateway-oss/) to provide
authentication and access to the rest of GIVE's microservices. GIVE uses a
microservices architecture, and the API gateway serves as the entrypoint to
those microservices.

## Why this project
The GIVE API Gateway aims to provide secure, unified access to GIVE
microservices. Without the gateway, GIVE would be a segmented collection of
related APIs, which sounds much less useful than a unified API providing
identity validation services. The API Gateway has the following goals:
* Secure access to GIVE services
* Provide a single entrypoint to GIVE services
* Manage inbound/outbound traffic

## CI/CD Workflows with GitHub Actions
The most up-to-date information about the CI/CD flows for this repo can be
found in the [GitHub workflows directory](https://github.com/18F/identity-give-gateway-service/tree/main/.github/workflows)

## Pre-requisites
If you plan to develop a new feature or add new code to this repo, you'll need
the following:
- [CF CLI](https://easydynamics.atlassian.net/wiki/spaces/GSATTS/pages/1252032607/Cloud.gov+CF+CLI+Setup)
- Cloud.gov account (Contact [Will Shah](mailto:wshah@easydynamics.com?subject=GSA%20Cloud.gov%20Account) to get one).

## Development Setup
You can test out kong features and configurations locally using the
[local Development steps](#Local-Development), and use the
[Cloud.gov development steps](#Cloud.gov-Development) when you're ready to test
in cloud.gov.

:bulb: Note: You will need to set up consumers and credentials within your test
instances. See the [OAuth2.0 section](#OAuth-2.0-Authorization) section for
details on how to set this up.

### Local Development
Local Kong development can be done by:
1. Installing Kong via the [Docker Installation](https://docs.konghq.com/install/docker/)
method. This is our preferred method, but you _can_ use one of the other
[Kong's supported install methods](https://konghq.com/install/).

    * The [Kong Docker-compose](https://github.com/Kong/docker-kong/tree/master/compose)
    template makes setting up the Kong docker install even easier. You can have
    Kong and a local postgres container running by simply running
    `docker-compose up`.

2. Sync the current GIVE configuration to your local Kong instance. GIVE uses
the [Kong decK CLI tool](https://docs.konghq.com/deck/overview/) to manage our
Kong configuration as code, so syncing the configuration should be as simple as
running `deck sync --skip-consumers`.

### Cloud.gov Development
To run a dev instance of the Kong service in cloud.gov, use the following steps:

1. Create a database to connect your Kong instance to during development (Don't
use the one other dev services are relying on being semi-stable!)
    * Use `cf create-service aws-rds micro-psql <your-test-db-name>` to start
    the DB creation process in cloud.gov
    * Wait for the DB to complete creating. You can use
    `watch -n 10 cf service <your-test-db-name>` and wait for the `status` to
    be `create succeeded`.

2. Modify the [manifest.yml](manifest.yml) file so that deployments don't step
on other's dev instances by changing:
    * The entire `routes` section to just `random-route: true`
    * The `give-api-gateway-data` service in the `services` with your DB
    service name from step 1.

3. Push your dev instance to cloud.gov by running `cf push --vars-file vars.yaml`.

## Admin API Access

:warning: Since GIVE manages the Kong configuration with
[decK](https://docs.konghq.com/deck/overview/), see about using the
[config file](kong.yaml) file to make changes before relying on the admin API
directly. decK practices configuration-as-code and will interact with the
admin API on your behalf. Only rely on the admin api if you *absolutely* have to.

If you still need direct access the Kong Admin API in cloud.gov, you can set up
SSH connections the app as shown below:

```shell
# To enable/disable SSH. See https://docs.cloudfoundry.org/devguide/deploy-apps/ssh-apps.html
cf enable-ssh <app-name>
cf disable-ssh <app-name>

# Typical SSH access
cf ssh <app-name>

# Or to set up an SSH tunnel
cf ssh -N -T -L 8081:localhost:8081 <app-name>
```

See the [Kong Admin API Documentation](https://docs.konghq.com/gateway-oss/2.3.x/admin-api/)
for details on usage.

:bulb: 8081 is set as the Admin API port in [manifest.yml](manifest.yml), along
with 8080 as the proxy port. These ports may vary during local development
depending on your settings, but will be 8080/8081 within cloud.gov.

## OAuth 2.0 Authorization

The GIVE API Gateway is deployed with a Kong
[OAuth 2.0 authorization plugin](https://docs.konghq.com/hub/kong-inc/oauth2/)
with [Client Credentials Grant Flow](https://tools.ietf.org/html/rfc6749#section-4.4)
enabled that all requests must follow. It should not be possible for any API
endpoint to be accessed without first going through the OAuth2.0 plugin.

### Setting up a new consumer
If you have a development instance running, you can add a new Kong Consumer and
OAuth credentials by running:
```shell
# This request will return an "id" that is needed for the next request.
curl -X POST http://localhost:8081/consumers/ \
    --data "username=<your-username>"

# This request will return the client_id and client_secret to generate OAuth tokens with
curl -X POST http://localhost:8081/consumers/<id-from-first-curl-response>/oauth2 \
    --data "name=Global%20OAuth%20Application"
```

### Generating tokens
Making requests to GIVE endpoints before this point will result in an error
message similar to "The access token is missing". In order to generate an
access token, make a POST request to
https://<give-api-gateway>/<service>/oauth2/token, and include the client_id,
client_secret, grant_type, and scope in the body of the request.

A request to a fictional "cool-service" endpoint would look like this:
```
curl -X POST https://give-api-gateway/ipp/oauth2/token \
    --data "grant_type=client_credentials" \
    --data "scope=rpname" \
    --data "client_id=client_id_from_earlier" \
    --data "client_secret=client_secret_from_earlier"
```

:warning: If you set up your development environment using the docker-compose
method, make sure you're using https to connect to the local instance as the
OAuth plugin will not allow http. By default the docker-compose method has this
set up using a self-signed cert, so local requests can accept use of
self-signed certs and be reasonably confident their environment is consistent
with what will be actually deployed.

## Changing the Kong Configuration
Configuration changes can be made by changing the [kong.yaml](kong.yaml)
configuration file, and syncing those changes with decK. This should be done
locally to ensure correctness, and validated using the `deck validate` command.

It may occasionally be necessary to make changes directly to the Kong admin API
and export that configuration to inspect the format that decK expects
configuration to be in. See the
[decK dump command](https://docs.konghq.com/deck/commands/#dump).

:bulb: New services added to Kong should automatically be secured with the
global OAuth2.0 plugin.

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in
[CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright
and related rights in the work worldwide are waived through the
[CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication.
By submitting a pull request, you are agreeing to comply with this waiver of
copyright interest.
