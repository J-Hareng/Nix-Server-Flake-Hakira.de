{ pkgs, ... }:
{
  services.jellyfin = {
    enable = true;
    package = pkgs.jellyfin;
    dataDir = "/home/admin/nxt/jellyfin";
    services.jellyfin.user = "admin";
  };
}
