{ config, pkgs, ... }:

let
  musicDir = "/srv/music"; # anpassen: dein Musikordner

  beetsConfig = (pkgs.formats.yaml { }).generate "beets-config.yaml" {
    directory = musicDir;
    library = "/var/lib/beets/library.db";
    plugins = [
      "fetchart"
      "embedart"
      "lastgenre"
    ];

    import = {
      copy = true;
      write = true;
      quiet_fallback = "skip";
      log = "/var/lib/beets/skipped.log";
    };

    fetchart.auto = true;
    embedart.auto = true;

    paths = {
      default = "$albumartist/$album%aunique{}/$disc-$track $title";
      comp = "Compilations/$album%aunique{}/$disc-$track $title";
      singleton = "Non-Album/$artist/$title";
    };
  };

  beetWrapper = pkgs.writeShellScriptBin "beet" ''
    export BEETSDIR=/var/lib/beets
    exec ${pkgs.beets}/bin/beet -c ${beetsConfig} "$@"
  '';
in
{
  environment.systemPackages = [ beetWrapper ];

  systemd.tmpfiles.rules = [
    "d /var/lib/beets 0775 navidrome navidrome -"
  ];

}
