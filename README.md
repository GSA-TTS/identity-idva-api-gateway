# GSA GIVE API Gateway

### Pre-requisites
- [Git Bash](https://git-scm.com/downloads)
- [CF CLI](https://easydynamics.atlassian.net/wiki/spaces/GSATTS/pages/1252032607/Cloud.gov+CF+CLI+Setup)
- Cloud.gov account (Contact [Will Shah](mailto:wshah@easydynamics.com?subject=GSA%20Cloud.gov%20Account) to get one).

### Setup

Follow the directions outlined in [Cloud.gov CLI Setup](https://easydynamics.atlassian.net/wiki/spaces/GSATTS/pages/1252032607/Cloud.gov+CF+CLI+Setup)

Setup a database layer for the API Gateway by running:

```
cf create-service aws-rds micro-psql kong-db
```

For more info about database service plans see 
- [Relational databases (RDS)](https://cloud.gov/docs/services/relational-database/)
- [Cloud.gov > Marketplace > Relational databases > Plans](https://dashboard.fr.cloud.gov/marketplace/2oBn9LBurIXUNpfmtZCQTCHnxUM/dcfb1d43-f22c-42d3-962c-7ae04eda24e7/plans)

To setup the API Gateway run:

```
cf push <your-gateway-name>
```
This creates a new API Gateway application in your sandbox environment with the the endpoint: https://your-gateway-name.app.cloud.gov. 

You can visit the [Cloud.gov Dashboard](https://dashboard.fr.cloud.gov/applications) to view the status of the deployment.


### Troubleshooting

Since this is not a compiled application, there isn't any debugging involved. You can set the [log level](https://docs.konghq.com/2.1.x/logging/) in the [manifest.yml](/manifest.yml) file and the view the logs in the Cloud.gov application dashboard under **Log Stream**.

Alternatively, you can use:

```
cf logs <your-gateway-name>
```
to tail the logs. Include `--recent` if you want to just dump the logs instead.

### HMAC Authentication

The API Gateway is secured with Kong's HMAC Authentication plugin. A digital signature is required in the header of a request that complies with the [Kong HMAC signature specification](https://docs.konghq.com/hub/kong-inc/hmac-auth/#signature-string-construction).

### References
- [cloud-gov/cf-kong](https://github.com/cloud-gov/cf-kong)
- [Kong Quickstart](https://docs.konghq.com/2.1.x/getting-started/quickstart/)
- [Kong Configuration Reference](https://docs.konghq.com/2.1.x/configuration/)