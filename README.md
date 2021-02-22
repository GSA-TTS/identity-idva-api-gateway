[![Maintainability](https://api.codeclimate.com/v1/badges/51007637d64a020ca966/maintainability)](https://codeclimate.com/github/18F/identity-give-gateway-service/maintainability)
# GIVE API Gateway
The Government Identity Verification Engine (GIVE) API gateway uses [Kong Gateway (OSS)](https://docs.konghq.com/gateway-oss/)
to provide authentication and access to the rest of GIVE's microservices. GIVE uses a microservices architecture,
and the API gateway serves as the entrypoint to those microservices.

## Pre-requisites
- [CF CLI](https://easydynamics.atlassian.net/wiki/spaces/GSATTS/pages/1252032607/Cloud.gov+CF+CLI+Setup)
- Cloud.gov account (Contact [Will Shah](mailto:wshah@easydynamics.com?subject=GSA%20Cloud.gov%20Account) to get one).

## Development Setup
You can test out kong features and configurations locally using the Local Development steps, and
use the Cloud.gov Development steps when you're ready to test in cloud.gov.

Note: You will need to set up consumers and credentials within your test instances. See the
[OAuth2.0 section](#OAuth-2.0-Authorization) section for details on how to set this up.

### Local Development
Local Kong development can be done by:
1. Installing Kong via the [Docker Installation](https://docs.konghq.com/install/docker/) method.
This is our preferred method, but you _can_ use one of the other [Kong's supported install methods](https://konghq.com/install/)).
    * The [Kong Docker-compose](https://github.com/Kong/docker-kong/tree/master/compose) template
    makes setting up the Kong docker install even easier. You can have Kong and a local postgres
    container running by simply running `docker-compose up`.

2. Sync the current GIVE configuration to your local Kong instance. GIVE uses the
[Kong decK CLI tool](https://docs.konghq.com/deck/overview/) to manage our Kong configuration as code,
so syncing the configuration should be as simple as running `deck sync --skip-consumers`.

### Cloud.gov Development
To run a dev instance of the Kong service in cloud.gov, use the following steps:

1. Create a database to connect your Kong instance to during development (Don't use the one other
dev services are relying on being semi-stable!)
    * Use `cf create-service aws-rds micro-psql <your-test-db-name>` to start the DB creation process in cloud.gov
    * Wait for the DB to complete creating. You can use `watch -n 10 cf service <your-test-db-name>`
    and wait for the `status` to be `create succeeded`.

2. Modify the [manifest.yml](manifest.yml) file so that deployments don't step on other's dev instances by changing:
    * The entire `routes` section to just `random-route: true`
    * The `give-api-gateway-data` service in the `services` with your DB service name from step 1.

3. Push your dev instance to cloud.gov by running `cf push --vars-file vars.yaml`.

## Admin API Access

To access the Kong Admin API, you can set up SSH connections the app as shown below:

```shell
# Typical SSH access
cf ssh <app-name>

# Or to set up an SSH tunnel
cf ssh -N -T -L 8081:localhost:8081 <app-name>
```

Note that 8081 is set as the Admin API port in [manifest.yml](manifest.yml), along with 8080 as the proxy port.


## OAuth 2.0 Authorization

The GIVE API Gateway is deployed with a Kong [OAuth 2.0 authorization plugin](https://docs.konghq.com/hub/kong-inc/oauth2/)
with [Client Credentials Grant Flow](https://tools.ietf.org/html/rfc6749#section-4.4) enabled that all requests must follow.

### Setting up a new consumer
If you have a development instance running, you can add a new Kong Consumer and OAuth credentials by running:
```shell
# This request will return an "id" that is needed for the next request.
curl -X POST http://localhost:8081/consumers/ \
    --data "username=<your-username>"

# This request will return the client_id and client_secret to generate OAuth tokens with
curl -X POST http://localhost:8081/consumers/<id-from-first-curl-response>/oauth2 \
    --data "name=Global%20OAuth%20Application"
```

### Generating tokens
Making requests to GIVE endpoints before this point will result in an error message similar to "The access token is missing".
In order to generate an access token, make a POST request to https://<give-api-gateway>/<service>/oauth2/token, and include
the client_id, client_secret, grant_type, and scope in the body of the request.

A request to a fictional "cool-service" endpoint would look like this:
```
curl -X POST https://give-api-gateway/ipp/oauth2/token \
    --data "grant_type=client_credentials" \
    --data "scope=rpname" \
    --data "client_id=client_id_from_earlier" \
    --data "client_secret=client_secret_from_earlier"
```

:warning: If you set up your development environment using the docker-compose method, make sure you're using https to connect
to the local instance as the OAuth plugin will not allow http. By default the docker-compose method has this set up using a
self-signed cert, so local requests can accept use of self-signed certs and be reasonably confident their environment is consistent
with what will be actually deployed.
