{
  config,
  pkgs,
  t3code,
  ...
}: {
  imports = [../modules/common.nix ../modules/llama-cpp.nix ../modules/niri.nix ../modules/plasma.nix ../modules/syncthing.nix];

  home.packages = [
    t3code.packages.${pkgs.stdenv.hostPlatform.system}.t3code-opencode
    pkgs.plattenalbum
  ];

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

  # Niri wm
  universe.niri.enable = false;

  # Plasma desktop
  universe.plasma.enable = true;

  # Local LLM using llama.cpp
  universe.llama-cpp = {
    enable = true;
    modelsPreset = {
      global.version = 1;
      models = {
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

  # Run syncthing on efficiency cores
  systemd.user.services.syncthing.Service.AllowedCPUs = "4-7";
}
