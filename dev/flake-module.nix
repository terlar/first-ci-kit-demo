{ inputs, ... }:

{
  imports = [
    inputs.dev-flake.flakeModule
    inputs.first-ci-kit.flakeModule
    inputs.process-compose.flakeModule
    ./ci.nix
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
        };

        first-ci-kit-gen-gitlab-ci = {
          enable = true;
          files = "^dev/(ci|stacks).nix$";
        };
      };
    };
}
