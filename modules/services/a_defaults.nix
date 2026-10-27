{ ... }:
{
  imports = [
    ./vaultwarden.nix
    ./beszel.nix
    ./tailscale.nix

    ./live-sync-obsidean.nix
    ./mcserver.nix
    ./reactive-resumay.nix
    ./minio.nix
    ./immich.nix
    ./degoog.nix
    ./stirling.nix

    ./auth/pocket-id.nix
    ./auth/tinyauth.nix

    ./music/beets.nix
    ./music/navidrome.nix
    ./music/copyparty.nix

    ./email/stalwart.nix
    ./email/webmail.nix
  ];
}
