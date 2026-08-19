{
  lib,
  pkgs,
  plasma-manager,
  voxtype,
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
    dotool
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
  # Manage Zed
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
    ];
    userSettings = {
      telemetry.metrics = false;
    };
  };

  # Manage VS Code
  programs.vscode = let
    commonSettings = {
      # This property will be used to generate settings.json:
      # https://code.visualstudio.com/docs/getstarted/settings#_settingsjson
      "chat.disableAIFeatures" = true;
      "chat.titleBar.signIn.enabled" = false;
      "editor.formatOnSave" = true;
      "editor.wordWrap" = "wordWrapColumn";
      "git.useIntegratedAskPass" = false;
      "window.commandCenter" = false;
      "window.menuBarVisibility" = "hidden";
      "window.titleBarStyle" = "native";
      "workbench.colorTheme" = "Light 2026";
      "workbench.layoutControl.enabled" = false;
      "workbench.startupEditor" = "none";
    };
    commonExtensions = with pkgs.vscode-marketplace-release; [
      mkhl.direnv
      saoudrizwan.claude-dev
    ];
  in {
    enable = true;
    profiles = {
      default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        userSettings = commonSettings;
        extensions = commonExtensions;
      };
      nix = {
        userSettings =
          commonSettings
          // {
            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "nil";
            "nix.serverSettings" = {
              nil.formatting.command = ["alejandra"];
            };
          };
        extensions =
          commonExtensions
          ++ [pkgs.vscode-marketplace-release.jnoortheen.nix-ide];
      };
      latex = {
        userSettings =
          commonSettings;
        extensions =
          commonExtensions
          ++ [
            pkgs.vscode-marketplace-release.streetsidesoftware.code-spell-checker
            pkgs.vscode-marketplace-release.streetsidesoftware.code-spell-checker-german
            pkgs.vscode-marketplace-release.james-yu.latex-workshop
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

  services.voxtype = {
    enable = true;
    package = voxtype.packages.${pkgs.stdenv.hostPlatform.system}.parakeet;
    loadModels = ["parakeet-tdt-0.6b-v3"];
    settings = {
      engine = "parakeet";
      state_file = "auto";
      parakeet = {
        model = "parakeet-tdt-0.6b-v3";
        on_demand_loading = true;
      };
      output = {
        mode = "type";
        fallback_to_clipboard = false;
        driver_order = ["dotool"];
        notification = {
          on_recording_start = true;
          on_recording_stop = true;
          on_transcription = false;
        };
      };
      hotkey = {
        enable = true;
        key = "CAPSLOCK";
        mode = "toggle";
      };
      osd = {
        enabled = false;
      };
    };
  };

  programs.plasma = {
    enable = true;
    overrideConfig = true;
    configFile = {
      # Make Caps Lock act as an additional Ctrl modifier, but keep identifying as Caps Lock so voxtype can capture it as hotkey
      kxkbrc = {
        Layout = {
          Options = "caps:ctrl_modifier";
          ResetOldOptions = true;
        };
      };
    };
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "vscode"
    ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
