{
  description = "Dependencies for development purposes";

  inputs = {
    dev-flake.url = "github:terlar/dev-flake";
    first-ci-kit = {
      url = "git+file:///home/terje/src/github.com/terlar/first-ci-kit?ref=github-improvements";
      inputs.flake-parts.follows = "dev-flake/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    process-compose.url = "github:platonic-systems/process-compose-flake";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = _: { };
}
