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
        kodiPkgs: [
          kodiPkgs.inputstream-adaptive
          kodiPkgs.pvr-iptvsimple
          kodiPkgs.youtube
          python312Packages.pillow
        ]
      ))
    ];
  };
}
