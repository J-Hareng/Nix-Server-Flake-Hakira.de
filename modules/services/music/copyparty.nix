{ ... }: {
  services.copyparty = {
    enable = true;
    user = "navidrome";
    group = "music";

    settings = {
      i = "127.0.0.1"; # nur lokal lauschen, nach außen geht es über den Proxy
      p = 3923;
    };

    accounts = {
      azazel.passwordFile = "/etc/secrets/copyparty/azazel.pw";
      admin.passwordFile = "/etc/secrets/copyparty/admin.pw";
    };

    volumes."/" = {
      path = "/srv/inbox";
      access = {
        w = [
          "azazel"
        ]; # nur hochladen
        A = [ "admin" ]; # du: alles
      };
    };
  };
}
