{ ... }:
{
  imports = [
    ./caddy.nix
    ./pocket-id.nix
    ./vaultwarden.nix
    ./beszel.nix
    ./tailscale.nix
    ./live-sync-obsidean.nix
    ./mcserver.nix
    ./navidrome.nix
    ./beets.nix

    ./music/beets.nix
    ./music/navidrome.nix

    ./email/stalwart.nix
    ./email/webmail.nix
  ];
}
