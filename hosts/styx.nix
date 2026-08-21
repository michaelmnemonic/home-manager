{
  config,
  pkgs,
  plasma-manager,
  t3code,
  voxtype,
  ...
}: {
  imports = [../modules/common.nix ../modules/syncthing.nix];

  home.packages = with pkgs; [
    elephant
    t3code.packages.${pkgs.stdenv.hostPlatform.system}.t3code-opencode
  ];

  home.file = {
    # Niri
    ".config/niri/config.kdl".source = ../dotfiles/niri/config.kdl;
    ".config/niri/keymap".source = ../dotfiles/niri/keymap;

    # Panel
    ".config/vibepanel/config.toml".source = ../dotfiles/vibepanel/config.toml;

    # Walker
    ".config/walker/themes/custom/style.css".source = ../dotfiles/walker/themes/custom/style.css;
  };

  age = {
    identityPaths = ["/home/maik/.ssh/id_ed25519" "/home/maik/.config/home-manager/secrets/age.key"];
    secrets = {
      "syncthing_styx_cert.pem".file = ../secrets/syncthing_styx_cert.pem.age;
      "syncthing_styx_key.pem".file = ../secrets/syncthing_styx_key.pem.age;
    };
  };

  universe.syncthing = {
    enable = true;
    device = "styx";
    cert = config.age.secrets."syncthing_styx_cert.pem".path;
    key = config.age.secrets."syncthing_styx_key.pem".path;
    folders = ["Bilder" "Bücher" "Dokumente" "Manga" "Musik"];
  };

  # Run syncthing on efficiency cores
  systemd.user.services.syncthing.Service.AllowedCPUs = "4-7";

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
      ExecStart = "${pkgs.elephant}/bin/elephant";
      Restart = "on-failure";
      RestartSec = "10";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
