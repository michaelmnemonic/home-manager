{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.universe.plasma;
in {
  options.universe.plasma = {
    enable = lib.mkEnableOption "An opinionated Plasma desktop setup";
  };
  imports = [./voxtype.nix];
  config = lib.mkIf cfg.enable {
    home.file = {
      ".config/mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = ../dotfiles/firefox/org.kde.plasma.browser_integration.json;
    };

    home.packages = with pkgs; [
      dotool
      playerctl
    ];

    programs.plasma = {
      enable = true;
      overrideConfig = true;
      desktop = {
        icons = {
          alignment = "right";
          arrangement = "topToBottom";
        };
        mouseActions.rightClick = "applicationLauncher";
        widgets = [];
      };
      input.touchpads = [
        {
          name = "CIRQ1080:00 0488:1082 Touchpad";
          enable = true;
          naturalScroll = true;
          productId = "1082";
          vendorId = "0488";
        }
      ];
      panels = [
        {
          location = "top";
          opacity = "opaque";
          floating = false;
          height = 27;
          widgets = [
            {name = "org.kde.plasma.windowlist";}
            {appMenu = {};}
            {panelSpacer.expanding = true;}
            {
              digitalClock = {
                date.enable = false;
                calendar = {
                  plugins = ["holidaysevents" "pimevents"];
                  showWeekNumbers = true;
                };
              };
            }
            {
              name = "org.kde.plasma.lock_logout";
              config.General = {
                actionsOrder = ["lockScreen" "switchUser" "requestShutDown" "requestReboot" "requestLogout" "requestLogoutScreen" "suspendToRam" "suspendToDisk"];
                show_lockScreen = false;
              };
            }
            {
              name = "org.kde.plasma.systemtray";
              config.General = {
                extraItems = [
                  "org.kde.kdeconnect"
                  "org.kde.plasma.cameraindicator"
                  "org.kde.plasma.clipboard"
                  "org.kde.plasma.devicenotifier"
                  "org.kde.plasma.manage-inputmethod"
                  "org.kde.plasma.mediacontroller"
                  "org.kde.plasma.notifications"
                  "org.kde.plasma.battery"
                  "org.kde.plasma.brightness"
                  "org.kde.plasma.keyboardindicator"
                  "org.kde.plasma.keyboardlayout"
                  "org.kde.plasma.volume"
                  "org.kde.plasma.weather"
                  "org.kde.kscreen"
                  "org.kde.plasma.bluetooth"
                  "org.kde.plasma.networkmanagement"
                  "org.kde.plasma.printmanager"
                ];
                disabledStatusNotifiers = ["steam"];
              };
            }
          ];
        }
      ];
      shortcuts = {
        "services/firefox.desktop".new-window = "Meta+B";
        "services/org.kde.konsole.desktop"._launch = ["Meta+Return" "Ctrl+Alt+T"];
        "services/org.kde.krunner.desktop"._launch = ["Alt+Space" "Alt+F2" "Meta" "Search"];
        "services/org.kde.plasma-systemmonitor.desktop"._launch = ["Ctrl+Shift+Esc" "Meta+Esc"];
        kwin."Window Close" = ["Alt+F4" "Meta+Q"];
      };
      configFile = {
        dolphinrc = {
          General = {
            RememberOpenedTabs = false;
            ShowFullPath = true;
            ShowFullPathInTitlebar = true;
          };
          "KFileDialog Settings" = {
            "Places Icons Auto-resize" = false;
            "Places Icons Static Size" = 22;
          };
          PreviewSettings.Plugins = "appimagethumbnail,audiothumbnail,windowsexethumbnail,imagethumbnail,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,jpegthumbnail,kraorathumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,fontthumbnail,svgthumbnail,ffmpegthumbs";
        };
        plasma-localerc.Formats.LANG = "de_DE.UTF-8";
        # Use natural scroll on touchpad
        kcminputrc."Libinput/1160/4226/CIRQ1080:00 0488:1082 Touchpad".NaturalScroll = true;
        # Use single click to open
        kdeglobals.KDE.SingleClick = true;
        # Make Caps Lock act as an additional Ctrl modifier, but keep identifying as Caps Lock so voxtype can capture it as hotkey
        kxkbrc = {
          Layout = {
            Options = "caps:ctrl_modifier";
            ResetOldOptions = true;
          };
        };
        # Start with an empty session
        ksmserverrc.General.loginMode = "emptySession";
        kwinrc = {
          Desktops.Id_1 = "765895f0-afa3-4fa5-acb6-6058f4806a19";
          Desktops.Id_2 = "b9cdd882-cc81-42c1-9a7d-821c1768a6a5";
          Desktops.Id_3 = "34d8cf95-0b3f-442b-9dde-f019d41ee3e3";
          Desktops.Id_4 = "7d6fc652-db5e-4292-9530-4df88f4af99d";
          Desktops = {
            Number = 4;
            Rows = 1;
          };
          Windows.BorderlessMaximizedWindows = true;
          Xwayland.Scale = 1.8;
          "org.kde.kdecoration2".ButtonsOnLeft = "SE";
        };
        kwinrulesrc = {
          General = {
            count = 1;
            rules = "ed35ba1d-fb14-4e6a-b23b-309082753aa5";
          };
          "ed35ba1d-fb14-4e6a-b23b-309082753aa5" = {
            Description = "BreezeDark für mpv";
            decocolor = "BreezeDark";
            decocolorrule = 2;
            wmclass = "mpv";
            wmclassmatch = 1;
          };
        };
      };
      workspace = {
        theme = "breeze-dark";
        splashScreen.theme = "None";
        wallpaperPlainColor = "111,111,111";
        cursor = {
          animationTime = 5;
          cursorFeedback = "Bouncing";
          size = 24;
          taskManagerFeedback = true;
          theme = "breeze_cursors";
        };
        iconTheme = "breeze";
        widgetStyle = "Breeze";
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
