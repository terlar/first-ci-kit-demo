{ lib, ... }:

{
  first-ci-kit.pipelines = {
    profile-tofu = {
      inputs = {
        stack.description = "Stack name";
        component.description = "Component name";
        deployment.description = "Deployment name";
      };

      gitlab-ci = {
        defaultStage = "main";
        transformJobName =
          name: "$[[ inputs.stack ]]_$[[ inputs.component ]]_$[[ inputs.deployment ]]_${name}";
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
          plan_needs = {
            type = "array";
            default = [ ];
            description = "Jobs that must complete before plan runs (cross-stack dependencies).";
          };
        };
      };

      github-actions = {
        defaultRunsOn = "ubuntu-latest";
        changes.enable = true;
      };

      jobSets.profile-tofu = {
        tags = [ "profile:tofu" ];
        jobDefaults = {
          image = "nixos/nix";
          env.NIX_CONFIG = "experimental-features = nix-command flakes";
          gitlab-ci.before_script = [
            "nix print-dev-env .#profile-tofu > profile-tofu.sh"
            ". profile-tofu.sh"
          ];
          github-actions.steps = lib.mkOrder 550 [
            {
              name = "Install Nix";
              uses = "cachix/install-nix-action@v31";
              "with".install_url = "https://releases.nixos.org/nix/nix-2.33.0/install";
            }
            {
              name = "Enter profile";
              run = ''
                nix print-dev-env .#profile-tofu > profile-tofu.sh
                echo "BASH_ENV=$PWD/profile-tofu.sh" >> "$GITHUB_ENV"
              '';
            }
          ];
        };
      };

      jobs = {
        plan = {
          tags = [ "profile:tofu" ];
          env.TF_IN_AUTOMATION = "1";
          gitlab-ci.needs = "$[[ inputs.plan_needs ]]";
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
          tags = [ "profile:tofu" ];
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

    default = lib.mkMerge [
      {
        gitlab-ci = {
          defaultStage = "main";
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
          };
        };

        process-compose.cli.environment.PC_DISABLE_TUI = true;

        jobSets = {
          stg.needs = [ { jobSet = "dev"; } ];
        };
      }

      (lib.pipe (import ./stacks.nix) [
        (lib.mapAttrsToList (
          stack: v:
          lib.mapAttrsToList (
            component:
            {
              needs ? [ ],
              ...
            }:
            lib.mapAttrsToList (deployment: _: {
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
                tags = [
                  "${stack}_${deployment}"
                  "${stack}_${component}_${deployment}"
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
                    templatePath = "gitlab-templates/profile-tofu/template.yml";
                    rulesInput = "rules";
                    pushRulesInput = "deploy_rules";
                    needsInputs = {
                      "plan_needs" = "deploy";
                    };
                  };
                };
              };
            }) v.deployments
          ) v.components
        ))
        lib.flatten
        (builtins.foldl' lib.recursiveUpdate { })
      ])
    ];
  };
}
