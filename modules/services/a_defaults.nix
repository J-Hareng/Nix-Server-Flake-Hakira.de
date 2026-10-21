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
    ./reactive-resumay.nix

    ./music/beets.nix
    ./music/navidrome.nix
    ./music/copyparty.nix

    ./email/stalwart.nix
    ./email/webmail.nix
  ];
}
