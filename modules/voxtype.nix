{
  config,
  lib,
  pkgs,
  voxtype,
  ...
}: let
  cfg = config.universe.voxtype;
in {
  options.universe.voxtype = {
    enable = lib.mkEnableOption "An opinionated voxtype setup";
    hotkey = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "If enabled, use the hotkey handler built into voxtype";
    };
    drive_order = lib.mkOption {
      type = lib.types.enum ["wtype" "dotool"];
      default = "dotool";
      description = "Name of program to use for typing";
    };
  };

  config = lib.mkIf cfg.enable {
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
        audio = {
          feedback.enabled = true;
          pause_media = true;
        };
        output = {
          mode = "type";
          fallback_to_clipboard = false;
          driver_order = [cfg.drive_order];
          notification = {
            on_recording_start = false;
            on_recording_stop = false;
            on_transcription = false;
          };
        };
        hotkey = {
          enable = cfg.hotkey;
          key = "CAPSLOCK";
          mode = "toggle";
        };
        osd = {
          enabled = false;
        };
      };
    };
  };
}
