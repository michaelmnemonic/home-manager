{
  config,
  lib,
  ...
}: let
  cfg = config.universe.syncthing;

  # Registry of all known Syncthing devices
  knownDevices = {
    "orpheus" = {
      id = "SBSFKPX-AX4SAS5-VY4J37B-55XWJAC-7MISPHG-UO6O735-WNQXIU2-7RDKAQW";
    };
    "pluto" = {
      id = "TEKLY3L-FETD5QI-5N5B5TN-ASLAXTP-KYX6IVX-SWVJRNI-2KSAV5K-HVSEGAO";
    };
    "juno" = {
      id = "5YXQUMF-QW6JZ72-XC2QFTJ-OIN2HBO-RP6NUFB-EALLFUT-LUBNH5I-PAWLDQ3";
    };
    "jupiter" = {
      id = "BY4REYT-QDK22NT-2AAUQTL-BZCG32F-3HSUFUB-V25GCQT-CJQQYSB-R4HUKQY";
    };
    "honda" = {
      id = "7T76EGY-KYOXTKG-A7P5TD7-5CEG4IT-6K2E5RU-VCRCDC6-Z6IVPN5-KVNJEQN";
    };
  };

  # Registry of all known Syncthing folders
  knownFolders = {
    "Bilder" = {
      id = "qgzgt-2xman";
      path = "~/Bilder";
      devices = ["orpheus" "pluto" "juno"];
    };
    "Bücher" = {
      id = "zmvzx-wr6md";
      path = "~/Bücher";
      devices = ["orpheus" "pluto" "juno"];
    };
    "Dokumente" = {
      id = "eznhn-uejrh";
      path = "~/Dokumente";
      devices = ["orpheus" "pluto" "juno"];
    };
    "Manga" = {
      id = "xeplb-hobg3";
      path = "~/Manga";
      devices = ["orpheus" "pluto" "juno"];
    };
    "Musik" = {
      id = "kcxtv-v5v5u";
      path = "~/Musik";
      devices = ["orpheus" "jupiter" "pluto" "juno" "honda"];
    };
    "Serien" = {
      id = "ooxu-xaev4";
      path = "~/Videos/Serien";
      devices = ["orpheus" "pluto" "juno"];
    };
  };

  # Build the active folders config from the selected folder names
  activeFolders = lib.genAttrs cfg.folders (name: knownFolders.${name});
in {
  options.universe.syncthing = {
    enable = lib.mkEnableOption "Syncthing file synchronization";

    device = lib.mkOption {
      type = lib.types.str;
      description = "Syncthing device name for this machine.";
    };

    cert = lib.mkOption {
      type = lib.types.str;
      description = "Path to the Syncthing certificate PEM file.";
    };

    key = lib.mkOption {
      type = lib.types.str;
      description = "Path to the Syncthing key PEM file.";
    };

    folders = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of folder names (from the registry) to sync on this device.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      cert = cfg.cert;
      key = cfg.key;
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices = knownDevices;
        folders = activeFolders;
      };
    };
  };
}
