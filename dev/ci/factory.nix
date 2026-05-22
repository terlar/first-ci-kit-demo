{
  first-ci-kit.pipelines.default = {
    stacks = import ../stacks.nix;

    defaultJobFactory = "tofu-component";

    jobFactories.tofu-component.fn =
      {
        stackName,
        componentName,
        deployment,
        formatJobName,
        needs,
        ...
      }:
      let
        jobName = formatJobName [
          stackName
          componentName
          deployment
        ];
        stackDeployment = formatJobName [
          stackName
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
              "terraform/${stackName}/${componentName}/**"
              "terraform/modules/component/**"
            ];
            triggers.onPush = true;
            triggers.onMergeRequest = true;
          };

          pipelineCall = {
            pipeline = "profile-tofu";
            inputs = {
              stack = stackName;
              component = componentName;
              inherit deployment;
            };
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
