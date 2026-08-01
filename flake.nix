{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    agenix,
    nixpkgs,
    nix-vscode-extensions,
    home-manager,
    ...
  }: let
    vscodeExtensionsOverlay = {
      nixpkgs.overlays = [nix-vscode-extensions.overlays.default];
    };
  in {
    devShells = nixpkgs.lib.genAttrs ["aarch64-linux" "x86_64-linux"] (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {packages = with pkgs; [nil alejandra agenix.packages.x86_64-linux.default];};
      }
    );

    homeConfigurations = {
      "maik@charon" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."aarch64-linux";
        modules = [
          vscodeExtensionsOverlay
          ./hosts/charon.nix
        ];
      };
      "maik@pluto" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          vscodeExtensionsOverlay
          ./hosts/pluto.nix
        ];
      };
      "maik@styx" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          vscodeExtensionsOverlay
          ./hosts/styx.nix
          agenix.homeManagerModules.default
        ];
      };
    };
  };
}
