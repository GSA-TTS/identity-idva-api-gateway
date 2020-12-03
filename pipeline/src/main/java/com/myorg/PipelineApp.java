package com.myorg;

import software.amazon.awscdk.core.App;

import java.util.Arrays;

public class PipelineApp {
    public static void main(final String[] args) {
        App app = new App();

        new PipelineStack(app, "sam-app-cicd-pipeline");

        app.synth();
    }
}
