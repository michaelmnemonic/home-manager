{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    nixpkgs,
    home-manager,
    ...
  }: {
    devShells = nixpkgs.lib.genAttrs ["aarch64-linux" "x86_64-linux"] (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {packages = [pkgs.alejandra];};
      }
    );

    homeConfigurations = {
      "maik@charon" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."aarch64-linux";
        modules = [./hosts/charon.nix];
        extraSpecialArgs = {
        };
      };
      "maik@pluto" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [./hosts/pluto.nix];
        extraSpecialArgs = {
        };
      };
    };
  };
}
