{ ... }:
{
  imports = [
    ./services/a_defaults.nix

    ./ssh.nix
    ./altert.nix
    ./firewall.nix
    ./packeges.nix
  ];

  services.dbus.implementation = "dbus";

}
