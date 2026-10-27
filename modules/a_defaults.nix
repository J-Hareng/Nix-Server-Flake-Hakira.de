{ ... }:
{
  imports = [
    ./services/a_defaults.nix

    ./caddy.nix
    ./ssh.nix
    ./altert.nix
    ./firewall.nix
    ./packeges.nix
  ];

  services.dbus.implementation = "dbus";

}
