package com.myorg;

import software.amazon.awscdk.core.Construct;
import software.amazon.awscdk.core.Stack;
import software.amazon.awscdk.core.StackProps;
import software.amazon.awscdk.core.CfnParameter;
import software.amazon.awscdk.core.CfnParameterProps;
import software.amazon.awscdk.core.SecretsManagerSecretOptions;
import software.amazon.awscdk.core.SecretValue;
import software.amazon.awscdk.services.s3.Bucket;
import software.amazon.awscdk.services.codebuild.*;
import software.amazon.awscdk.services.codecommit.*;
import software.amazon.awscdk.services.codepipeline.*;
import software.amazon.awscdk.services.codepipeline.actions.*;
import software.amazon.awscdk.services.secretsmanager.*;
import java.util.*;
import static software.amazon.awscdk.services.codebuild.LinuxBuildImage.AMAZON_LINUX_2;

public class PipelineStack extends Stack {
    public PipelineStack(final Construct scope, final String id) {
        this(scope, id, null);
    }

    public PipelineStack(final Construct scope, final String id, final StackProps props) {
        super(scope, id, props);

        CfnParameter secretsManagerSecretId = new CfnParameter(this, "secretsManagerSecretId", CfnParameterProps.builder()
                .type("String")
                .description("The id of the secrets manager secret used to store the GitHub oauth token.")
                .build());
        CfnParameter secretsManagerJsonKey = new CfnParameter(this, "secretsManagerJsonKey", CfnParameterProps.builder()
                .type("String")
                .description("The json key corresponding to the oauth token in the Secret.")
                .build());

        // The code that defines your stack goes here
        Bucket artifactsBucket = new Bucket(this, "ArtifactsBucket");

        Pipeline pipeline = new Pipeline(this, "Pipeline", PipelineProps.builder()
                .artifactBucket(artifactsBucket).build());

        Artifact sourceOutput = new Artifact("sourceOutput");

        GitHubSourceAction gitHubSource = new GitHubSourceAction(GitHubSourceActionProps.builder()
                .actionName("GitHub_Source")
                .repo("identity-give-gateway-service")
                .owner("dzaslavskiy")
                .branch("main")
                .oauthToken(SecretValue.secretsManager(secretsManagerSecretId.getValueAsString(), SecretsManagerSecretOptions.builder()
                        .jsonField(secretsManagerJsonKey.getValueAsString())
                        .build()))
                .output(sourceOutput)
                .build());

        pipeline.addStage(StageOptions.builder()
                .stageName("Source")
                .actions(Collections.singletonList(gitHubSource))
                .build());

        // Declare build output as artifacts
        Artifact buildOutput = new Artifact("buildOutput");

        // Declare a new CodeBuild project
        PipelineProject buildProject = new PipelineProject(this, "Build", PipelineProjectProps.builder()
                .environment(BuildEnvironment.builder()
                        .buildImage(AMAZON_LINUX_2).build())
                .environmentVariables(Collections.singletonMap("PACKAGE_BUCKET", BuildEnvironmentVariable.builder()
                        .value(artifactsBucket.getBucketName())
                        .build()))
                .build());

        // Add the build stage to our pipeline
        CodeBuildAction buildAction = new CodeBuildAction(CodeBuildActionProps.builder()
                .actionName("Build")
                .project(buildProject)
                .input(sourceOutput)
                .outputs(Collections.singletonList(buildOutput))
                .build());

        pipeline.addStage(StageOptions.builder()
                .stageName("Build")
                .actions(Collections.singletonList(buildAction))
                .build());

        // Deploy stage
        CloudFormationCreateReplaceChangeSetAction createChangeSet = new CloudFormationCreateReplaceChangeSetAction(CloudFormationCreateReplaceChangeSetActionProps.builder()
                .actionName("CreateChangeSet")
                .templatePath(buildOutput.atPath("packaged.yaml"))
                .stackName("gateway-service")
                .adminPermissions(true)
                .changeSetName("gateway-service-changeset")
                .runOrder(1)
                .build());

        CloudFormationExecuteChangeSetAction executeChangeSet = new CloudFormationExecuteChangeSetAction(CloudFormationExecuteChangeSetActionProps.builder()
                .actionName("Deploy")
                .stackName("sam-app")
                .changeSetName("gateway-service-changeset")
                .runOrder(2)
                .build());

        pipeline.addStage(StageOptions.builder()
                .stageName("Dev")
                .actions(Arrays.asList(createChangeSet, executeChangeSet))
                .build());
    }

}
