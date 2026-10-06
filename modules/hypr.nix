{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.universe.hypr;
in {
  options.universe.hypr = {
    enable = lib.mkEnableOption "An opinionated Hyprland session";
  };
  imports = [./voxtype.nix];
  config = lib.mkIf cfg.enable {
    home.file = {
      # Hyprland
      ".config/hypr/hyprland.lua".source = ../dotfiles/hypr/hyprland.lua;

      # Hyprpaper
      ".config/hypr/hyprpaper.conf".source = ../dotfiles/hypr/hyprpaper.conf;
      ".config/hypr/wallpaper.jpg".source = ../assets/wallpaper.jpg;

      # Hyprlock
      ".config/hypr/hyprlock.conf".source = ../dotfiles/hypr/hyprlock.conf;
      ".config/hypr/lockscreen.jpg".source = ../assets/lockscreen.jpg;

      # Hypridle
      ".config/hypr/hypridle.conf".source = ../dotfiles/hypr/hypridle.conf;

      # Panel
      ".config/vibepanel/config.toml".source = ../dotfiles/vibepanel/config.toml;

      # Walker
      ".config/walker/themes/custom/style.css".source = ../dotfiles/walker/themes/custom/style.css;
    };

    home.packages = with pkgs; [
      elephant
      hypridle
      hyprlock
      hyprpaper
      playerctl
      resources
      wtype
    ];

    # Hyprpaper
    systemd.user.services.hyprpaper = {
      Unit = {
        Description = "hyprpaper is a fast, IPC-controlled wallpaper utility for Hyprland";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
        Requisite = ["graphical-session.target"];
      };
      Service = {
        Slice = "session.slice";
        ExecStart = lib.getExe pkgs.hyprpaper;
        Restart = "on-failure";
        RestartSec = "10";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    # Hypridle
    systemd.user.services.hypridle = {
      Unit = {
        Description = "hypridle is an idle management daemon for Hyprland";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
        Requisite = ["graphical-session.target"];
      };
      Service = {
        Slice = "session.slice";
        ExecStart = lib.getExe pkgs.hypridle;
        Restart = "on-failure";
        RestartSec = "10";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

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

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita";
      };
      gtk4.theme = null;
    };

    dconf.settings = {
      "org.gnome.desktop.interface" = {
        "accent-color" = "purple";
        "font-name" = "Inter Variable 11";
        "monospace-font-name" = "JetBrains Mono 10";
      };
      "org.gnome.desktop.wm.preferences" = {
        "button-layout" = "appmenu:close";
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
