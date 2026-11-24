{ ... }:
{
  imports = [
    ./vaultwarden.nix
    ./beszel.nix

    ./live-sync-obsidean.nix
    ./mcserver.nix
    ./reactive-resumay.nix
    ./immich.nix
    ./degoog.nix
    ./stirling.nix

    ./open-webui

    ./matrix

    ./vpn

    ./auth/pocket-id.nix
    ./auth/tinyauth.nix

    ./music/beets.nix
    ./music/navidrome.nix

    ./email/stalwart.nix
    ./email/webmail.nix
  ];
}
