{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.universe.llama-cpp;
  configFile = pkgs.writeText "llama-cpp-models-preset.ini" (
    lib.generators.toINIWithGlobalSection {} {
      globalSection = cfg.modelsPreset.global;
      sections = cfg.modelsPreset.models;
    }
  );
  # one download command per configured model; keys are `owner/repo:quant`
  downloadCommands = map (
    model: "${pkgs.llama-cpp-vulkan}/bin/llama-fit-params -hf ${model}"
  ) (builtins.attrNames cfg.modelsPreset.models);
  # optional authentication for llama-server
  apiKeyArgs =
    lib.optionals (cfg.apiKeyFile != null) ["--api-key-file ${cfg.apiKeyFile}"];
in {
  options.universe.llama-cpp = {
    enable = lib.mkEnableOption "Local LLM setup with llama.cpp";

    apiKeyFile = lib.mkOption {
      description = ''
        Path to a file containing API key(s) passed as `--api-key-file` to
        llama-server (one key per line). Requests without a valid key are
        rejected. If `null`, the server accepts unauthenticated requests.
      '';
      type = with lib.types; nullOr (either str path);
      default = null;
    };

    modelsPreset = lib.mkOption {
      description = ''
        Contents of the llama-server `--models-preset` file.
      '';
      type = lib.types.submodule {
        options = {
          global = lib.mkOption {
            description = "Global section applied to all models.";
            type = with lib.types; attrsOf (oneOf [bool int float str]);
            default = {};
          };
          models = lib.mkOption {
            description = ''
              Per-model sections keyed by Hugging Face model id
              (`owner/repo:quant`).
            '';
            type = with lib.types; attrsOf (attrsOf (oneOf [bool int float str]));
            default = {};
          };
        };
      };
    };
  };
  config = lib.mkIf cfg.enable {
    # an empty ExecStart= list would produce an invalid systemd unit
    assertions = [
      {
        assertion = cfg.modelsPreset.models != {};
        message = "universe.llama-cpp: at least one model must be configured under modelsPreset.models.";
      }
    ];
    systemd.user.services = {
      "llama-cpp-downloader" = {
        Unit = {
          Description = "Download local models using llama.cpp";
        };
        Service = {
          Type = "oneshot";
          # a potentially long-running download must not be killed by the default 90s start timeout
          TimeoutStartSec = "infinity";
          RemainAfterExit = true;
          Slice = "background.slice";
          # llama-fit-params is not actually the correct tool, but llama.cpp does not provide a download-only tool
          ExecStart = downloadCommands;
          Restart = "on-failure";
          RestartSec = "10";
          RestartSteps = "6";
          RestartMaxDelaySec = "8min";
        };
        Install = {
          WantedBy = ["default.target"];
        };
      };
      "llama-cpp-router" = {
        Unit = {
          Description = "Route inference to local models using llama.cpp";
          After = ["llama-cpp-downloader.service"];
          Requires = ["llama-cpp-downloader.service"];
        };
        Service = {
          Type = "simple";
          Slice = "background.slice";
          ExecStart =
            lib.concatStringsSep
            " "
            ([
                "${pkgs.llama-cpp-vulkan}/bin/llama-server"
                "--models-preset ${configFile}"
                "--models-max 1"
                "--sleep-idle-seconds 30"
                "--port 38101"
              ]
              ++ apiKeyArgs);
          Restart = "on-failure";
          RestartSec = "10";
          RestartSteps = "6";
          RestartMaxDelaySec = "8min";
        };
        Install = {
          WantedBy = ["default.target"];
        };
      };
    };
  };
}
