{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.universe.niri;
in {
  options.universe.niri = {
    enable = lib.mkEnableOption "An opinionated Niri session";
  };
  imports = [./voxtype.nix];
  config = lib.mkIf cfg.enable {
    home.file = {
      # Niri
      ".config/niri/config.kdl".source = ../dotfiles/niri/config.kdl;
      ".config/niri/keymap".source = ../dotfiles/niri/keymap;

      # Panel
      ".config/vibepanel/config.toml".source = ../dotfiles/vibepanel/config.toml;

      # Walker
      ".config/walker/themes/custom/style.css".source = ../dotfiles/walker/themes/custom/style.css;
    };

    home.packages = with pkgs; [
      elephant
    ];

    # Vibepanel
    systemd.user.services.vibepanel = {
      Unit = {
        Description = "GTK4 panel for Wayland with notifications, OSD, and quick settings – between a status bar and a desktop shell.";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
        Requisite = ["graphical-session.target"];
      };
      Service = {
        Slice = "session.slice";
        ExecStart = "/run/current-system/sw/bin/vibepanel";
        Restart = "on-failure";
        RestartSec = "10";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    # Walker
    services.walker = {
      enable = true;
      systemd.enable = true;
      settings = {
        app_launch_prefix = "systemd-run --user --slice=app-interactive.slice --scope ";
        as_window = false;
        close_when_open = false;
        disable_click_to_close = false;
        force_keyboard_focus = false;
        hotreload_theme = false;
        locale = "";
        monitor = "";
        terminal_title_flag = "";
        theme = "custom";
        timeout = 0;
      };
    };

    # Data provider and executor for walker
    systemd.user.services.elephant = {
      Unit = {
        Description = "Data provider and executor";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
        Requisite = ["graphical-session.target"];
      };
      Service = {
        Slice = "session.slice";
        ExecStart = lib.getExe pkgs.elephant;
        Restart = "on-failure";
        RestartSec = "10";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    # Voxtype
    universe.voxtype = {
      enable = true;
      hotkey = false;
      drive_order = "wtype";
    };
  };
}
