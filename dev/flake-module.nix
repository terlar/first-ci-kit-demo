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

      packages.gen-stack-diagram = pkgs.buildGoModule {
        pname = "gen-stack-diagram";
        version = "0.1.0";
        src = ../tools/gen-stack-diagram;
        vendorHash = null;
      };

      treefmt = {
        programs.nixfmt = {
          enable = true;
          package = pkgs.nixfmt-rfc-style;
        };
      };

      devShells.profile-tofu = pkgs.mkShell {
        packages = [ pkgs.opentofu ];
      };

      pre-commit.check.enable = false;
      pre-commit.settings.hooks = {
        first-ci-kit-gen-github-actions = {
          enable = true;
          files = "^dev/(ci|stacks).nix$";
          settings.pipelines = {
            default = ".github/workflows/ci.yml";
            profile-tofu = ".github/workflows/profile-tofu.yml";
          };
        };

        first-ci-kit-gen-gitlab-ci = {
          enable = true;
          files = "^dev/(ci|stacks).nix$";
          settings.pipelines = {
            default = ".gitlab-ci.yml";
            profile-tofu = "gitlab-templates/profile-tofu/template.yml";
          };
        };

        gen-stack-diagram = {
          enable = true;
          name = "Generate stack diagram";
          entry = pkgs.lib.getExe (
            pkgs.writeShellApplication {
              name = "gen-stack-diagram-hook";
              runtimeInputs = [ config.packages.gen-stack-diagram ];
              text = ''
                nix eval --json --impure --expr 'import ./dev/stacks.nix' \
                  | gen-stack-diagram
              '';
            }
          );
          files = "^dev/stacks\\.nix$";
          pass_filenames = false;
          language = "system";
        };
      };
    };
}
