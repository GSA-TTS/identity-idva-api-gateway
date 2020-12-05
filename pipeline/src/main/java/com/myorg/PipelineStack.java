package com.myorg;

import software.amazon.awscdk.core.Construct;
import software.amazon.awscdk.core.Stack;
import software.amazon.awscdk.core.StackProps;
import software.amazon.awscdk.core.SecretsManagerSecretOptions;
import software.amazon.awscdk.core.SecretValue;
import software.amazon.awscdk.services.s3.Bucket;
import software.amazon.awscdk.services.codebuild.*;
import software.amazon.awscdk.services.codepipeline.*;
import software.amazon.awscdk.services.codepipeline.actions.*;
import java.util.*;
import static software.amazon.awscdk.services.codebuild.LinuxBuildImage.AMAZON_LINUX_2;

public class PipelineStack extends Stack {
    public PipelineStack(final Construct scope, final String id) {
        this(scope, id, null);
    }

    public PipelineStack(final Construct scope, final String id, final StackProps props) {
        super(scope, id, props);

        // The code that defines your stack goes here
        Bucket artifactsBucket = new Bucket(this, "ArtifactsBucket");

        Pipeline pipeline = new Pipeline(this, "Pipeline", PipelineProps.builder()
                .artifactBucket(artifactsBucket).build());

        Artifact sourceOutput = new Artifact("sourceOutput");

        SecretValue connectionARN = SecretValue.secretsManager("give_github_connection_arn",
                        SecretsManagerSecretOptions.builder()
                                        .jsonField("arn")
                                        .build()
        );

        // Don't be fooled by the name, the source code is being pulled from GitHub but the 
        // BitBucketSourceAction is the only CDK souce action construct that uses a CodeStar
        // connection to integrate with an outside ource. See https://github.com/aws/aws-cdk/issues/10632
        BitBucketSourceAction gitHubSource = new BitBucketSourceAction(BitBucketSourceActionProps.builder()
                .actionName("GitHub_Source")
                .connectionArn(connectionARN.toString())
                .repo("identity-give-gateway-service")
                .owner("18F")
                .branch("main")
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
        String stack_name = "gateway-service";
        String change_set_name = stack_name + "-changeset";
        CloudFormationCreateReplaceChangeSetAction createChangeSet = new CloudFormationCreateReplaceChangeSetAction(CloudFormationCreateReplaceChangeSetActionProps.builder()
                .actionName("CreateChangeSet")
                .templatePath(buildOutput.atPath("packaged.yaml"))
                .stackName(stack_name)
                .adminPermissions(true)
                .changeSetName(change_set_name)
                .runOrder(1)
                .build());

        CloudFormationExecuteChangeSetAction executeChangeSet = new CloudFormationExecuteChangeSetAction(CloudFormationExecuteChangeSetActionProps.builder()
                .actionName("Deploy")
                .stackName(stack_name)
                .changeSetName(change_set_name)
                .runOrder(2)
                .build());

        pipeline.addStage(StageOptions.builder()
                .stageName("Dev")
                .actions(Arrays.asList(createChangeSet, executeChangeSet))
                .build());
    }

}
