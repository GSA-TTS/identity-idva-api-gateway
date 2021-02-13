[![Maintainability](https://api.codeclimate.com/v1/badges/51007637d64a020ca966/maintainability)](https://codeclimate.com/github/18F/identity-give-gateway-service/maintainability)
# GSA GIVE API Gateway

### Pre-requisites
- [CF CLI](https://easydynamics.atlassian.net/wiki/spaces/GSATTS/pages/1252032607/Cloud.gov+CF+CLI+Setup)
- [Python 3.9](https://www.python.org/downloads/release/python-390/#:~:text=Files%20%20%20%20Version%20%20%20,%20%208757017%20%206%20more%20rows)
- Cloud.gov account (Contact [Will Shah](mailto:wshah@easydynamics.com?subject=GSA%20Cloud.gov%20Account) to get one).

### Initial Setup

Follow the directions outlined in [Cloud.gov CLI Setup](https://docs.cloudfoundry.org/cf-cli/)

Setup a database layer for the API Gateway by running:

```
cf create-service aws-rds micro-psql kong-db
```

For more info about database service plans see the [cloud.gov Relational databases (RDS)](https://cloud.gov/docs/services/relational-database/) page.

To setup the API Gateway run:

```
cf push <your-gateway-name>
```
This creates a new API Gateway application in your sandbox environment with the the endpoint: https://your-gateway-name.app.cloud.gov. 

You can visit the [Cloud.gov Dashboard](https://dashboard.fr.cloud.gov/applications) to view the status of the deployment.

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


### OAuth 2.0 Authorization

The GIVE API Gateway is deployed with a Kong OAuth 2.0 authorization plugin with Client Credentials Grant enabled. All requests must follow the [Client Credentials Grant Flow](https://tools.ietf.org/html/rfc6749#section-4.4).

### Troubleshooting

You can set the [log level](https://docs.konghq.com/2.1.x/logging/) in the [manifest.yml](/manifest.yml) file and the view the logs in the Cloud.gov application dashboard under **Log Stream**.

Alternatively, you can use:

```
cf logs <your-gateway-name>
```
to tail the logs. Include `--recent` if you want to just dump the logs instead.

### References
- [cloud-gov/cf-kong](https://github.com/cloud-gov/cf-kong)
- [Kong Quickstart](https://docs.konghq.com/2.1.x/getting-started/quickstart/)
- [Kong Configuration Reference](https://docs.konghq.com/2.1.x/configuration/)
