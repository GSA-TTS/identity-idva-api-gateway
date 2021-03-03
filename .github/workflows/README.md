# GitHub Actions CI/CD workflows

## Deploy Dev
Deploys the project to the GIVE dev environment within Cloud.gov. The
deploy-dev workflow will only be triggered in the 18F repository. This will
prevent forks from needlessly running workflows that will always fail
(forks won't be able to authenticate into the dev environment).

## Stale Items
The stale-items workflow will run once per day and mark issues and PR's as
stale if they have not seen any activity over the last 30 days. After being
marked stale for 5 days, the workflow will close the item.

## Validate Config
The validte-config workflow will install the Kong decK tool and run a
`deck validate` against the current kong.yaml deck config file to ensure that
there are no detectable format errors within the file.
