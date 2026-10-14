{ ... }:
{
  imports = [
    ./caddy.nix
    ./pocket-id.nix
    ./vaultwarden.nix
    ./beszel.nix
    ./tailscale.nix
    ./live-sync-obsidean.nix

    ./email/stalwart.nix
    ./email/webmail.nix
  ];
}
