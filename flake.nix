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
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    t3code = {
      url = "github:michaelmnemonic/t3code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    voxtype = {
      url = "github:peteonrails/voxtype/8d49248baa53f29cb33007c9625a37281c72e799"; # v0.7.5
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };
  outputs = {
    agenix,
    catppuccin,
    home-manager,
    nix-vscode-extensions,
    nixpkgs,
    plasma-manager,
    t3code,
    voxtype,
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
        extraSpecialArgs = {inherit t3code;};
        modules = [
          vscodeExtensionsOverlay
          ./hosts/pluto.nix
        ];
      };
      "maik@styx" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = {inherit catppuccin t3code voxtype;};
        modules = [
          agenix.homeManagerModules.default
          catppuccin.homeModules.catppuccin
          plasma-manager.homeModules.plasma-manager
          voxtype.homeManagerModules.default
          vscodeExtensionsOverlay
          ./hosts/styx.nix
        ];
      };
    };
  };
}
