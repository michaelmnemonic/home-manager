{
  config,
  lib,
  ...
}: let
  cfg = config.universe.gnome;
in {
  options.universe.gnome = {
    enable = lib.mkEnableOption "An opinionated GNOME desktop setup";
  };
  imports = [./voxtype.nix];
  config = lib.mkIf cfg.enable {
    dconf.enable = true;

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        accent-color = "purple";
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = ":close";
      };
      "org/gnome/shell" = {
        favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "firefox.desktop"
          "org.gnome.Calendar.desktop"
          "io.github.quodlibet.QuodLibet.desktop"
          "kodi.desktop"
          "steam.desktop"
          "dev.zed.Zed.desktop"
          "code.desktop"
          "t3code.desktop"
          "org.gnome.Console.desktop"
        ];
      };
    };

    # Voxtype
    universe.voxtype = {
      enable = true;
      hotkey = true;
      drive_order = "dotool";
    };
  };
}
