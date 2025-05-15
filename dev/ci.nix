{ lib, ... }:

{
  first-ci-kit.pipelines.default = lib.mkMerge [
    {
      pipeline = {
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
          settings = {
            name = "CI";
            on.push = {
              branches = [ "main" ];
            };
            on.pull_request = {
              branches = [ "main" ];
            };
          };
        };

        process-compose.cli.environment.PC_DISABLE_TUI = true;
      };

      jobSets = {
        stg.needs = [ { jobSet = "dev"; } ];
      };

      jobInterfaces = {
        terraformEnvJobs =
          {
            stack,
            component,
            deployment,
            ...
          }:
          {
            "${stack}_${component}_validate" = {
              commands = [ "echo tofu validate" ];
            };

            "${stack}_${component}_${deployment}_plan" = {
              needs = [
                {
                  job = "${stack}_${component}_validate";
                  artifacts = false;
                  optional = true;
                }
              ];

              tags = [
                deployment
                "${stack}_${deployment}"
                "${stack}_${component}_${deployment}"
              ];

              commands = [ "echo tofu plan" ];
            };

            "${stack}_${component}_${deployment}_deploy" = {
              needs = [
                { job = "${stack}_${component}_${deployment}_plan"; }
              ];

              tags = [
                deployment
                "${stack}_${deployment}"
                "${stack}_${component}_${deployment}"
              ];

              commands = [ "echo tofu deploy" ];
            };
          };
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

              jobs = config.jobInterfaces.terraformEnvJobs {
                inherit stack component deployment;
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
