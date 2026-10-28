{ ... }:
{
  imports = [
    ./vaultwarden.nix
    ./beszel.nix
    ./tailscale.nix

    ./live-sync-obsidean.nix
    ./mcserver.nix
    ./reactive-resumay.nix
    ./immich.nix
    ./degoog.nix
    ./stirling.nix

    ./auth/pocket-id.nix
    ./auth/tinyauth.nix

    ./music/beets.nix
    ./music/navidrome.nix

    ./email/stalwart.nix
    ./email/webmail.nix
  ];
}
