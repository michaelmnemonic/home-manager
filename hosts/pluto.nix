{
  pkgs,
  t3code,
  ...
}: {
  imports = [
    ../modules/common.nix
    ../modules/llama-cpp.nix
    ../modules/niri.nix
    ../modules/plasma.nix
    ../modules/syncthing.nix
  ];

  home.packages = [
    t3code.packages.${pkgs.stdenv.hostPlatform.system}.t3code-opencode
    pkgs.calibre-no-speech
  ];

  # Niri wm
  universe.niri.enable = true;
}
