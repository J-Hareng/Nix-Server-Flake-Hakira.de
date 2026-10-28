{ ... }:
let
  home = "/home/admin";
in
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "${home}/.config/sops/age/keys.txt";
  };
}
