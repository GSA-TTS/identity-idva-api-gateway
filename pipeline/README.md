# Welcome to your CDK Java project!

This is CI/CD pipleline project for Java development with the AWS CDK.

The `cdk.json` file tells the CDK Toolkit how to execute your app.

It is a [Maven](https://maven.apache.org/) based project, so you can open this project with any Maven compatible Java IDE to build and run tests.

# Overview
This CDK project builds the CI/CD pipeline for an [AWS SAM application](https://aws.amazon.com/serverless/sam/), and includes stages for GitHub Souce integration, building the SAM app, and deploying the changes via a cloudformation changeset.

To deploy the pipeline, make sure you've got your AWS credentials set up and run `mvn clean package` followed by a `cdk deploy`.



## Useful commands

 * `mvn package`     compile and run tests
 * `cdk ls`          list all stacks in the app
 * `cdk synth`       emits the synthesized CloudFormation template
 * `cdk deploy`      deploy this stack to your default AWS account/region
 * `cdk diff`        compare deployed stack with current state
 * `cdk docs`        open CDK documentation

Enjoy!
