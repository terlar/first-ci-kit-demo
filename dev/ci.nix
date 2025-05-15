{ lib, ... }:

{
  first-ci-kit.pipelines.default = lib.mkMerge [
    {
      pipeline = {
        gitlab-ci = {
          defaultStage = "main";
          settings = {
            stages = [ "main" ];
            workflow.rules = [
              { "if" = "$CI_MERGE_REQUEST_TARGET_BRANCH_PROTECTED"; }
              { "if" = "$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH"; }
            ];
          };
        };

        github-actions.settings = {
          name = "CI";
          on.push = {
            branches = [ "main" ];
          };
          on.pull_request = {
            branches = [ "main" ];
          };
        };
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
            "${stack}:${component}:validate" = {
              commands = [ "echo tofu validate" ];
            };

            "${stack}:${component}:${deployment}:plan" = {
              needs = [
                {
                  job = "${stack}:${component}:validate";
                  artifacts = false;
                  optional = true;
                }
              ];

              tags = [
                deployment
                "${stack}:${deployment}"
                "${stack}:${component}:${deployment}"
              ];

              commands = [ "echo tofu plan" ];
            };

            "${stack}:${component}:${deployment}:deploy" = {
              needs = [
                { job = "${stack}:${component}:${deployment}:plan"; }
              ];

              tags = [
                deployment
                "${stack}:${deployment}"
                "${stack}:${component}:${deployment}"
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
                "${stack}:${deployment}".tags = [ "${stack}:${deployment}" ];
                "${stack}:${component}:${deployment}" = {
                  tags = [ "${stack}:${component}:${deployment}" ];
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
                            (builtins.concatStringsSep ":")
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
