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
in {
  options.universe.llama-cpp = {
    enable = lib.mkEnableOption "Local LLM setup with llama.cpp";

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
          ExecStart = [
            "${pkgs.llama-cpp-vulkan}/bin/llama-fit-params -hf unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_XL"
            "${pkgs.llama-cpp-vulkan}/bin/llama-fit-params -hf unsloth/gemma-4-12B-it-qat-GGUF:UD-Q4_K_XL"
            "${pkgs.llama-cpp-vulkan}/bin/llama-fit-params -hf unsloth/gemma-4-E4B-it-qat-GGUF:UD-Q4_K_XL"
          ];
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
          ExecStart = "${pkgs.llama-cpp-vulkan}/bin/llama-server --models-preset ${configFile} --models-max 1 --sleep-idle-seconds 30";
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
