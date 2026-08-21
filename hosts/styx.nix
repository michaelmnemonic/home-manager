{
  config,
  pkgs,
  plasma-manager,
  t3code,
  voxtype,
  ...
}: {
  imports = [../modules/common.nix ../modules/syncthing.nix];

  home.packages = [
    t3code.packages.${pkgs.stdenv.hostPlatform.system}.t3code-opencode
  ];

  home.file = {
    # Niri
    ".config/niri/config.kdl".source = ../dotfiles/niri/config.kdl;
    ".config/niri/keymap".source = ../dotfiles/niri/keymap;

    # Panel
    ".config/vibepanel/config.toml".source = ../dotfiles/vibepanel/config.toml;
  };

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

  # Run syncthing on efficiency cores
  systemd.user.services.syncthing.Service.AllowedCPUs = "4-7";
}
