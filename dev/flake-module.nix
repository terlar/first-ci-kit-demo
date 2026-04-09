{ inputs, ... }:

{
  imports = [
    inputs.dev-flake.flakeModule
    inputs.first-ci-kit.flakeModules.default
    inputs.first-ci-kit.flakeModules.git-hooks
    inputs.first-ci-kit.flakeModules.process-compose
    inputs.process-compose.flakeModule
    ./ci.nix
  ];

  systems = [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ];

  dev.name = "first-ci-kit-demo";
  debug = true;

  perSystem =
    { config, pkgs, ... }:
    {
      formatter = config.treefmt.programs.nixfmt.package;

      treefmt = {
        programs.nixfmt = {
          enable = true;
          package = pkgs.nixfmt-rfc-style;
        };
      };

      pre-commit.check.enable = false;
      pre-commit.settings.hooks = {
        first-ci-kit-gen-github-actions = {
          enable = true;
          files = "^dev/(ci|stacks).nix$";
          settings.reusableWorkflows.default = {
            "stack-a_cmp-a_dev" = ".github/workflows/stack-a_cmp-a_dev.yml";
            "stack-a_cmp-a_stg" = ".github/workflows/stack-a_cmp-a_stg.yml";
            "stack-a_cmp-b_dev" = ".github/workflows/stack-a_cmp-b_dev.yml";
            "stack-a_cmp-b_stg" = ".github/workflows/stack-a_cmp-b_stg.yml";
            "stack-a_cmp-c_dev" = ".github/workflows/stack-a_cmp-c_dev.yml";
            "stack-a_cmp-c_stg" = ".github/workflows/stack-a_cmp-c_stg.yml";
            "stack-b_cmp-a_dev" = ".github/workflows/stack-b_cmp-a_dev.yml";
            "stack-b_cmp-a_stg" = ".github/workflows/stack-b_cmp-a_stg.yml";
            "stack-b_cmp-b_dev" = ".github/workflows/stack-b_cmp-b_dev.yml";
            "stack-b_cmp-b_stg" = ".github/workflows/stack-b_cmp-b_stg.yml";
            "stack-c_cmp-a_dev" = ".github/workflows/stack-c_cmp-a_dev.yml";
            "stack-c_cmp-a_stg" = ".github/workflows/stack-c_cmp-a_stg.yml";
            "stack-c_cmp-b_dev" = ".github/workflows/stack-c_cmp-b_dev.yml";
            "stack-c_cmp-b_stg" = ".github/workflows/stack-c_cmp-b_stg.yml";
            "stack-c_cmp-c_dev" = ".github/workflows/stack-c_cmp-c_dev.yml";
            "stack-c_cmp-c_stg" = ".github/workflows/stack-c_cmp-c_stg.yml";
            "stack-d_cmp-a_dev" = ".github/workflows/stack-d_cmp-a_dev.yml";
            "stack-d_cmp-a_stg" = ".github/workflows/stack-d_cmp-a_stg.yml";
            "stack-e_cmp-a_dev" = ".github/workflows/stack-e_cmp-a_dev.yml";
            "stack-e_cmp-a_stg" = ".github/workflows/stack-e_cmp-a_stg.yml";
            "stack-e_cmp-b_dev" = ".github/workflows/stack-e_cmp-b_dev.yml";
            "stack-e_cmp-b_stg" = ".github/workflows/stack-e_cmp-b_stg.yml";
            "stack-f_cmp-a_dev" = ".github/workflows/stack-f_cmp-a_dev.yml";
            "stack-f_cmp-a_stg" = ".github/workflows/stack-f_cmp-a_stg.yml";
          };
        };

        first-ci-kit-gen-gitlab-ci = {
          enable = true;
          files = "^dev/(ci|stacks).nix$";
        };
      };
    };
}
