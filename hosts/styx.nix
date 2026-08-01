{config, ...}: {
  imports = [../modules/common.nix ../modules/syncthing.nix];

  config.age = {
    identityPaths = ["/home/maik/.ssh/id_ed25519" "/home/maik/.config/home-manager/secrets/age.key"];
    secrets = {
      "syncthing_styx_cert.pem".file = ../secrets/syncthing_styx_cert.pem.age;
      "syncthing_styx_key.pem".file = ../secrets/syncthing_styx_key.pem.age;
    };
  };

  config.universe.syncthing = {
    enable = true;
    device = "styx";
    cert = config.age.secrets."syncthing_styx_cert.pem".path;
    key = config.age.secrets."syncthing_styx_key.pem".path;
    folders = ["Bilder" "Bücher" "Dokumente" "Manga" "Musik"];
  };

  # Run syncthing on efficiency cores
  config.systemd.user.services.syncthing.Service.AllowedCPUs = "4-7";
}
