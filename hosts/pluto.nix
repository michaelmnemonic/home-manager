{
  pkgs,
  t3code,
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

  # Niri wm
  universe.niri.enable = true;

  # Local LLM using llama.cpp
  universe.llama-cpp.enable = true;

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
