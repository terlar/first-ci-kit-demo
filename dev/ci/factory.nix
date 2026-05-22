{
  first-ci-kit.pipelines.default = {
    stackDiscovery = {
      enable = true;
      path = ../../terraform;
    };

    defaultJobFactory = "tofu-component";

    jobFactories.tofu-component.fn =
      {
        stack,
        component,
        deployment,
        formatJobName,
        needs,
        ...
      }:
      let
        jobName = formatJobName [
          stack
          component
          deployment
        ];
        stackDeployment = formatJobName [
          stack
          deployment
        ];
      in
      {
        jobSets = {
          ${deployment}.tags = [ deployment ];
          ${stackDeployment}.tags = [ stackDeployment ];
          ${jobName} = {
            tags = [ jobName ];
            inherit needs;
          };
        };

        jobs.${jobName} = {
          tags = [
            stackDeployment
            jobName
          ];
          branches.default = {
            changes.paths = [
              "terraform/${stack}/${component}/**"
              "terraform/modules/component/**"
            ];
            triggers.onPush = true;
            triggers.onMergeRequest = true;
          };

          pipelineCall = {
            pipeline = "profile-tofu";
            inputs = { inherit stack component deployment; };
            gitlab-ci = {
              rulesInput = "rules";
              pushRulesInput = "deploy_rules";
              needsInputs."plan_needs" = "deploy";
            };
          };
        };
      };
  };
}
