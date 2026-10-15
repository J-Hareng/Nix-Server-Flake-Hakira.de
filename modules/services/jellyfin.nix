{ pkgs, ... }:
{
  services.jellyfin = {
    enable = true;
    services.jellyfin.package = pkgs.jellyfin;
    dataDir = "/home/admin/nxt/jellyfin";
  };
}
