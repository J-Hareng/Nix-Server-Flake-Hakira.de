{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    navidrome
    copyparty
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
    };
  };

  services.copyparty = {
    enable = true;
    group = "music";
    settings = {
      i = "127.0.0.1";
      p = [ 3923 ];
      rproxy = 1;
    };
    accounts = {
      admin.passwordFile = "/var/lib/copyparty/admin.pw";
      berry.passwordFile = "/var/lib/copyparty/berry.pw";
    };
    volumes."/" = {
      path = "/srv/music";
      access = {
        A = [ "admin" ];
        w = [ "berry" ];
      };
    };
  };

}
