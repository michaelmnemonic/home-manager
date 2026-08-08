{pkgs, t3code, ...}: {
  imports = [../modules/common.nix];

  home.packages = [
    t3code.packages.${pkgs.stdenv.hostPlatform.system}.t3code-opencode
  ];
}
