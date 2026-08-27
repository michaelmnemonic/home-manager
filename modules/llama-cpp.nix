{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.universe.llama-cpp;
  configFile = pkgs.writeText "config.ini" (
    lib.generators.toINIWithGlobalSection {} {
      globalSection = {
        version = 1;
      };
      sections = {
        "unsloth/Qwen3.8-27B-GGUF:UD-IQ3_XXS" = {
          ctx-size = 100000;

          # Thinking
          chat-template-kwargs = "{ \"reasoning_effort\" : \"medium\" }";

          # Batch
          batch-size = 8192;
          ubatch-size = 1024;

          parallel = 1;
          flash-attn = "on";
          fit = "off";
          jinja = true;

          # Cache
          cache-type-k = "q8_0";
          cache-type-v = "q4_0";
          cache-prompt = true;
          cache-reuse = 0;
          cache-ram = 0;
          no-cache-idle-slots = true;

          # Speculative Decoding
          spec-type = "draft-mtp,ngram-map-k4v";
          spec-draft-n-max = 2;
          spec-draft-p-min = 0.3;
          spec-ngram-mod-n-min = 4;
          spec-ngram-mod-n-max = 8;
          spec-ngram-mod-n-match = 32;

          # CPU
          threads = 8;
          threads-batch = 8;

          # Temps
          temperature = 0.7;
          top-k = 20;
          top-p = 0.95;
          min-p = 0.0;
          presence-penalty = 0.0;
          repeat-penalty = 1.0;

          reasoning = "on";
          no-warmup = true;
          swa-checkpoints = "5";
          checkpoint-min-step = 32768;
        };
        "unsloth/gemma-4-12B-it-qat-GGUF:UD-Q4_K_XL" = {
          c = 8192;
          jinja = true;
        };
        "unsloth/gemma-4-E4B-it-qat-GGUF:UD-Q4_K_XL" = {
          c = 16000;
          jinja = true;
          reasoning = "off";
        };
      };
    }
  );
in {
  options.universe.llama-cpp = {
    enable = lib.mkEnableOption "Local LLM setup with llama.cpp";
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
