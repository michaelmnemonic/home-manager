{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.universe.kodi;
in {
  options.universe.kodi = {
    enable = lib.mkEnableOption "An opinionated kodi setup";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (pkgs.kodi-wayland.withPackages (
        kodiPkgs:
          with pkgs; [
            kodiPackages.pvr-iptvsimple
            kodiPackages.youtube
            python312Packages.pillow
          ]
      ))
    ];
  };
}
