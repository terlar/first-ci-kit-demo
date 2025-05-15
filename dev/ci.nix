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
              commands = [ "echo tofu plan" ];
              tags = [
                stack
                "${stack}:${component}"
                deployment
              ];
            };
            "${stack}:${component}:${deployment}:deploy" = {
              commands = [ "echo tofu deploy" ];
              tags = [
                stack
                "${stack}:${component}"
                deployment
              ];
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
                ${stack} = {
                  needs = lib.mkIf (needs != [ ]) (
                    map (need: {
                      jobSet =
                        lib.pipe
                          [
                            (need.stack or stack)
                            (need.component or "")
                          ]
                          [
                            (lib.lists.remove "")
                            (builtins.concatStringsSep ":")
                          ];
                    }) needs
                  );
                  tags = [ stack ];
                };
                ${deployment}.tags = [ deployment ];
                "${stack}:${component}".tags = [ "${stack}:${component}" ];
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
