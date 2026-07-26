{
  pkgs,
  lib,
  ...
}: {
  home.username = "maik";
  home.homeDirectory = "/home/maik";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "heavy-run" ''
      exec systemd-run --user --slice=app-heavy.slice --scope "$@"
    '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/maik/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "michaelmnemonic";
        email = "michaelmnemonic@posteo.eu";
      };
    };
  };

  xdg.configFile = {
    "systemd/user/pipewire.service.d/slice.conf".text = ''
      [Service]
      Slice=realtime.slice
    '';
    "systemd/user/pipewire-pulse.service.d/slice.conf".text = ''
      [Service]
      Slice=realtime.slice
    '';
    "systemd/user/wireplumber.service.d/slice.conf".text = ''
      [Service]
      Slice=realtime.slice
    '';
  };

  # Move syncthing to background slice
  systemd.user.services.syncthing.Service.Slice = "background.slice";

  # Automatically update this home
  services.home-manager.autoUpgrade = {
    enable = true;
    frequency = "daily";
  };

  systemd.user.slices = {
    "session.slice" = {
      Unit = {Description = "Session shell services";};
      Slice = {
        CPUWeight = 800;
        MemoryHigh = "4G";
        ManagedOOMPreference = "avoid";
      };
    };
    "app-interactive.slice" = {
      Unit = {Description = "Interactive apps";};
      Slice = {
        CPUWeight = 500;
        MemoryHigh = "6G";
        MemoryMax = "8G";
        ManagedOOMPreference = "avoid";
      };
    };
    "app-heavy.slice" = {
      Unit = {Description = "Heavy apps";};
      Slice = {
        CPUWeight = 100;
        MemoryHigh = "4G";
        MemoryMax = "6G";
        ManagedOOMPreference = "oom";
      };
    };
    "realtime.slice" = {
      Unit = {Description = "Real-time audio";};
      Slice = {
        CPUWeight = 950;
        MemoryHigh = "2G";
        ManagedOOMPreference = "avoid";
      };
    };
    "background.slice" = {
      Unit = {Description = "Background services";};
      Slice = {
        CPUWeight = 50;
        MemoryHigh = "2G";
        MemoryMax = "3G";
        ManagedOOMPreference = "oom";
      };
    };
  };
  # Manager VS Code
  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        userSettings = {
          # This property will be used to generate settings.json:
          # https://code.visualstudio.com/docs/getstarted/settings#_settingsjson
          "chat.disableAIFeatures" = true;
          "chat.titleBar.signIn.enabled" = false;
          "editor.formatOnSave" = true;
          "window.commandCenter" = false;
          "window.menuBarVisibility" = "hidden";
          "window.titleBarStyle" = "native";
          "workbench.colorTheme" = "Light 2026";
          "workbench.layoutControl.enabled" = false;
          "workbench.startupEditor" = "none";
        };
        extensions = with pkgs.vscode-marketplace-release; [
          mkhl.direnv
          saoudrizwan.claude-dev
        ];
      };
      nix = {
        userSettings = {
          # This property will be used to generate settings.json:
          # https://code.visualstudio.com/docs/getstarted/settings#_settingsjson
          "chat.disableAIFeatures" = true;
          "chat.titleBar.signIn.enabled" = false;
          "editor.formatOnSave" = true;
          "window.commandCenter" = false;
          "workbench.colorTheme" = "Light 2026";
          "workbench.layoutControl.enabled" = false;
          "workbench.startupEditor" = "none";
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nil";
          "nix.serverSettings" = {
            nil.formatting.command = ["alejandra"];
          };
        };
        extensions = with pkgs.vscode-marketplace-release; [
          mkhl.direnv
          saoudrizwan.claude-dev
          jnoortheen.nix-ide
        ];
      };
    };
  };

  programs.kodi = {
    enable = true;
    package = pkgs.kodi-wayland.withPackages (
      kodiPkgs:
        with pkgs; [
          python312Packages.pillow
        ]
    );
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "vscode"
    ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
