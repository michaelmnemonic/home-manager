{
  description = "Home Manager configuration of maik";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vibepanel = {
      url = "github:prankstr/vibepanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    nixpkgs,
    home-manager,
    noctalia,
    vibepanel,
    ...
  }: let
    mkHome = system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [./home.nix noctalia.homeModules.default];
      };
  in {
    homeConfigurations = {
      "maik@charon" = mkHome "aarch64-linux";
    };
  };
}
