let
  age = "age1um5lyf48x2zryr8c48tt84gw7xamt8c9f7df00jtxtqg0ml2ccts3vr9f9";
  maik_at_styx = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINM1F2ryn8sYFz2SwtPezNMJzFewcZC/WqTY6f6B86vq";
  users = [maik_at_styx];

  styx = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdsANWJFiP9zrry7LG5qws7NTlbMzvDxqfeNTPOZpk1";
  systems = [styx];
in {
  "syncthing_styx_cert.pem.age".publicKeys = [age] ++ users ++ systems;
  "syncthing_styx_key.pem.age".publicKeys = [age] ++ users ++ systems;
}
