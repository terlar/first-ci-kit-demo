{ lib, ... }:

{
  first-ci-kit.pipelines.profile-tofu = {
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
          ". ./profile-tofu.sh"
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
          "tofu -chdir=terraform/$STACK/$COMPONENT init -backend-config=deployments/$DEPLOYMENT/backend.tfbackend"
          "tofu -chdir=terraform/$STACK/$COMPONENT validate"
          "tofu -chdir=terraform/$STACK/$COMPONENT plan -var-file=deployments/$DEPLOYMENT/terraform.tfvars -out=tfplan"
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
          "tofu -chdir=terraform/$STACK/$COMPONENT init -backend-config=deployments/$DEPLOYMENT/backend.tfbackend"
          "tofu -chdir=terraform/$STACK/$COMPONENT apply -auto-approve tfplan"
        ];
        artifacts.download = {
          name = "\${{ inputs.stack }}-\${{ inputs.component }}-\${{ inputs.deployment }}-plan";
          path = "terraform/$STACK/$COMPONENT";
        };
      };
    };
  };
}
