{ ... }:
{
  imports = [
    ./services/a_defaults.nix

    ./sops.nix
    ./ssh.nix
    ./altert.nix
    ./packeges.nix
    ./net.nix
  ];

  services.dbus.implementation = "dbus";

}
