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

### Local Development
Local Kong development can be done by:
1. Installing Kong via one the [Kong's supported install methods](https://konghq.com/install/).

2. Generate the Kong configuration file (kong.yaml) from the
[kong-config.yaml](kong-config.yaml). This can be done by running `envsubst < kong-config.yaml > kong.yaml`
after setting the `ENVIRONMENT_NAME` variable to one of `dev`, `test`, or `prod`.
Note that unless deployed to cloud.gov, the urls of upstream services defined in kong.yaml
will not be reachable from your local kong instance. The 
[Kong decK CLI tool](https://docs.konghq.com/deck/overview/) can still be used to
manage validate the kong.yaml file by running `deck validate --state kong.yaml`.
Similarly, Kong can validate the kong.conf file by running `kong check ./kong.conf`

3. Start your local Kong instance. Run `kong start -c ./kong.conf` to run your local
Kong Gateway. Locally the only thing you should be able to do is validate that the 
correct configuration settings have been applied via the admin API.

### Cloud.gov Development
To run a dev instance of the Kong service in cloud.gov, use the following steps:

1. Modify the [manifest.yml](manifest.yml) file so that deployments don't step
on other's dev instances by changing:
    * The `name` of the application to something unique (perhaps including your username
      to prevent stranded test applications)
    * The entire `routes` section to just `random-route: true`

2. Push your dev instance to cloud.gov by running `cf push --vars-file vars.yaml --var ENVIRONMENT_NAME=dev`.

## Admin API Access

:warning: Since GIVE manages the Kong configuration with a declarative configuration file,
the admin API is set to read-only mode. Changes will have to be made by restarting kong with
a new configuration file.

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

## Changing the Kong Configuration
Configuration changes can be made by changing the [kong-config.yaml](kong-config.yaml)
configuration file, and pushing those changes with the cf cli. Changes should be
performed locally to ensure correctness, and validated using the `deck validate`
command after generating the config file (see [local development](#Local-Development)
for info on how).

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
