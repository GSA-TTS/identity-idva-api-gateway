""" pipeline_stack.py defines the CI/CD pipeline for an AWS SAM application """
from aws_cdk import (
    core,
    aws_s3 as s3,
    aws_codepipeline as codepipeline,
    aws_codepipeline_actions as pipeline_actions,
    aws_codebuild as codebuild,
)


class PipelineStack(core.Stack):
    """ PipelineStack defines the CI/CD pipeline for this application """

    def __init__(
        self,
        scope: core.Construct,
        construct_id: str,
        repo_owner: str,
        repo_name: str,
        **kwargs,
    ) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # The code that defines your stack goes here
        connection_secret_id = core.CfnParameter(
            self,
            "ConnectionSecretId",
            description="SecretsManager Secret ID for the CodeStar connection ARN. The JSON key for the secret must be 'arn'",
        )

        pipeline = codepipeline.Pipeline(
            self, "Pipeline", artifact_bucket=s3.Bucket(self, "ArtifactBucket")
        )

        # Define the 'source' stage to be triggered by a webhook on the GitHub
        # repo for the code. Don't be fooled by the name, it's just a codestar
        # connection in the background. Bitbucket isn't involved.
        source_output = codepipeline.Artifact("SourceOutput")
        github_source = pipeline_actions.BitBucketSourceAction(
            action_name="Github_Source",
            connection_arn=core.SecretValue.secrets_manager(
                secret_id=connection_secret_id.value_as_string, json_field="arn"
            ).to_string(),
            repo=repo_name,
            owner=repo_owner,
            branch="main",
            output=source_output,
        )
        pipeline.add_stage(stage_name="Source", actions=[github_source])

        # Define the 'build' stage
        build_project = codebuild.PipelineProject(
            scope=self,
            id="Build",
            # Declare the pipeline artifact bucket name as an environment variable
            # so the build can send the deployment package to it.
            environment_variables={
                "PACKAGE_BUCKET": codebuild.BuildEnvironmentVariable(
                    value=pipeline.artifact_bucket.bucket_name,
                    type=codebuild.BuildEnvironmentVariableType.PLAINTEXT,
                )
            },
            environment=codebuild.BuildEnvironment(
                build_image=codebuild.LinuxBuildImage.STANDARD_3_0
            ),
        )
        build_stage_output = codepipeline.Artifact("BuildStageOutput")
        build_action = pipeline_actions.CodeBuildAction(
            action_name="Build",
            project=build_project,
            input=source_output,
            outputs=[build_stage_output],
        )
        pipeline.add_stage(stage_name="Build", actions=[build_action])

        # Define the 'deploy' stage
        stack_name = construct_id
        change_set_name = f"{stack_name}-changeset"

        create_change_set = pipeline_actions.CloudFormationCreateReplaceChangeSetAction(
            action_name="CreateChangeSet",
            stack_name=stack_name,
            change_set_name=change_set_name,
            template_path=build_stage_output.at_path("packaged.yaml"),
            admin_permissions=True,
            run_order=1,
        )
        execute_change_set = pipeline_actions.CloudFormationExecuteChangeSetAction(
            action_name="Deploy",
            stack_name=stack_name,
            change_set_name=change_set_name,
            run_order=2,
        )
        pipeline.add_stage(
            stage_name="DevDeployment", actions=[create_change_set, execute_change_set]
        )
