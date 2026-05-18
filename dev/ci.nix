{ lib, ... }:

{
  first-ci-kit.pipelines.profile-tofu = {
    inputs = {
      stack.description = "Stack name";
      component.description = "Component name";
      deployment.description = "Deployment name";
    };

    gitlab-ci = {
      transformJobName =
        name: "$[[ inputs.stack ]]:$[[ inputs.component ]]:$[[ inputs.deployment ]]:${name}";
      inputs = {
        rules = {
          type = "array";
          default = [ ];
          description = "GitLab CI rules for the plan job.";
        };
        deploy_rules = {
          type = "array";
          default = [ ];
          description = "GitLab CI rules for the deploy job.";
        };
      };
      settings.asComponent = true;
    };

    github-actions.defaultRunsOn = "ubuntu-latest";

    jobs = {
      plan = {
        env.TF_IN_AUTOMATION = "1";
        commands = [
          "tofu -chdir=terraform/$STACK/$COMPONENT init -backend-config=deployments/$DEPLOYMENT.tfbackend"
          "tofu -chdir=terraform/$STACK/$COMPONENT validate"
          "tofu -chdir=terraform/$STACK/$COMPONENT plan -var-file=deployments/$DEPLOYMENT.tfvars -out=tfplan"
        ];
        artifacts.upload = {
          name = "\${{ inputs.stack }}-\${{ inputs.component }}-\${{ inputs.deployment }}-plan";
          paths = [ "terraform/$STACK/$COMPONENT/tfplan" ];
          retentionDays = 7;
        };
      };

      deploy = {
        env.TF_IN_AUTOMATION = "1";
        needs = [ { job = "plan"; } ];
        commands = [
          "tofu -chdir=terraform/$STACK/$COMPONENT init -backend-config=deployments/$DEPLOYMENT.tfbackend"
          "tofu -chdir=terraform/$STACK/$COMPONENT apply -auto-approve tfplan"
        ];
        artifacts.download = {
          name = "\${{ inputs.stack }}-\${{ inputs.component }}-\${{ inputs.deployment }}-plan";
          path = "terraform/$STACK/$COMPONENT";
        };
      };
    };
  };

  first-ci-kit.pipelines.default = lib.mkMerge [
    {
      gitlab-ci = {
        defaultStage = "main";
        transformJobName = builtins.replaceStrings [ "_" ] [ ":" ];
        settings = {
          default.image = "alpine";
          stages = [ "main" ];
          workflow.rules = [
            { "if" = "$CI_MERGE_REQUEST_TARGET_BRANCH_PROTECTED"; }
            { "if" = "$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH"; }
          ];
        };
      };

      github-actions = {
        defaultRunsOn = "ubuntu-latest";
        summaryJob.enable = true;
        settings = {
          name = "CI";
          on.push.branches = [ "main" ];
          on.pull_request.branches = [ "main" ];
        };
      };

      process-compose.cli.environment.PC_DISABLE_TUI = true;

      jobSets = {
        stg.needs = [ { jobSet = "dev"; } ];
      };
    }

    (
      { config, ... }:
      lib.pipe ./stacks.nix [
        import
        (lib.mapAttrsToList (
          stack: v:
          (lib.mapAttrsToList (
            component:
            {
              needs ? [ ],
              ...
            }:
            (lib.mapAttrsToList (deployment: _: {
              jobSets = {
                ${deployment}.tags = [ deployment ];
                "${stack}_${deployment}".tags = [ "${stack}_${deployment}" ];
                "${stack}_${component}_${deployment}" = {
                  tags = [ "${stack}_${component}_${deployment}" ];
                  needs = lib.mkIf (needs != [ ]) (
                    map (need: {
                      jobSet =
                        lib.pipe
                          [
                            (need.stack or stack)
                            (need.component or "")
                            deployment
                          ]
                          [
                            (lib.lists.remove "")
                            (builtins.concatStringsSep "_")
                          ];
                    }) needs
                  );
                };
              };

              jobs."${stack}_${component}_${deployment}" = {
                pipelineCall = {
                  pipeline = "profile-tofu";
                  inputs = {
                    stack = stack;
                    component = component;
                    deployment = deployment;
                  };
                  gitlab-ci = {
                    templatePath = "ci/gitlab-templates/profile-tofu/template.yml";
                    rulesInput = "rules";
                    pushRulesInput = "deploy_rules";
                  };
                };
              };
            }) v.deployments)
          ) v.components)
        ))
        lib.flatten
        (builtins.foldl' lib.recursiveUpdate { })
      ]
    )
  ];
}
