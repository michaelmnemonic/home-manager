{
  config,
  pkgs,
  t3code,
  ...
}: {
  imports = [../modules/common.nix ../modules/niri.nix ../modules/syncthing.nix];

  home.packages = [
    t3code.packages.${pkgs.stdenv.hostPlatform.system}.t3code-opencode
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

  # Run syncthing on efficiency cores
  systemd.user.services.syncthing.Service.AllowedCPUs = "4-7";
}
