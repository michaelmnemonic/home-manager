let
  age = "age1ree37mdgyetpczd9d3cgywdl3wmen5atxp7lv9e5j4mdsrtmd9hsznty4w";
  maik_at_styx = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINM1F2ryn8sYFz2SwtPezNMJzFewcZC/WqTY6f6B86vq";
  users = [maik_at_styx];

  styx = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdsANWJFiP9zrry7LG5qws7NTlbMzvDxqfeNTPOZpk1";
  systems = [styx];
in {
  "syncthing_styx_cert.pem.age".publicKeys = [age] ++ users ++ systems;
  "syncthing_styx_key.pem.age".publicKeys = [age] ++ users ++ systems;
}
