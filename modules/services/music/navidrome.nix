{ pkgs, Domain, ... }:
{
  environment.systemPackages = with pkgs; [
    navidrome
  ];

  users.groups.music = {
  };

  systemd.tmpfiles.rules = [
    "d /srv/music 2775 admin music -"
  ];

  services.navidrome = {
    enable = true;
    group = "music";

    settings = {
      Address = "127.0.0.1";
      Port = 4533;
      MusicFolder = "/srv/music";
      PID.Album = "musicbrainz_albumid|albumartistid,album,albumversion";
    };
  };

  services.caddy.virtualHosts."media.${Domain}".extraConfig = ''
    reverse_proxy http://127.0.0.1:4533
  '';
}
