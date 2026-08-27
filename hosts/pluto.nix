{
  pkgs,
  t3code,
  config,
  ...
}: {
  imports = [
    ../modules/common.nix
    ../modules/llama-cpp.nix
    ../modules/niri.nix
    ../modules/plasma.nix
    ../modules/syncthing.nix
  ];

  home.packages = [
    t3code.packages.${pkgs.stdenv.hostPlatform.system}.t3code-opencode
    pkgs.calibre-no-speech
    pkgs.plattenalbum
  ];

  age = {
    identityPaths = ["/home/maik/.ssh/id_ed25519" "/home/maik/.config/home-manager/secrets/age.key"];
    secrets = {
      "llama-cpp_pluto.key".file = ../secrets/llama-cpp_pluto.key.age;
    };
  };

  # Niri wm
  universe.niri.enable = true;

  # Local LLM using llama.cpp
  universe.llama-cpp = {
    enable = true;
    apiKeyFile = config.age.secrets."llama-cpp_pluto.key".path;
    modelsPreset = {
      global.version = 1;
      models = {
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
    };
  };

  # mpd
  services.mpd = {
    enable = true;
    network.startWhenNeeded = true;
    musicDirectory = "/home/maik/Musik";
    extraConfig = ''
      auto_update "yes"

      audio_output {
        type            "pipewire"
        name            "PipeWire output"
      }
    '';
  };
}
