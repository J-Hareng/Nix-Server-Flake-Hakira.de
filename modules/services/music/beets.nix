{ config, pkgs, ... }:

let
  beetsConfig = (pkgs.formats.yaml { }).generate "beets-config.yaml" {
    directory = "/srv/music";
    library = "/var/lib/beets/library.db";
    plugins = [
      "musicbrainz"
      "chroma"
      "fetchart"
      "lastgenre"
    ];

    import = {
      copy = true;
      write = true;
      quiet_fallback = "skip";
      duplicate_action = "skip"; # schon vorhandene Alben nicht doppelt anlegen
      incremental = true; # bereits verarbeitete Ordner nicht nochmal anfassen
      incremental_skip_later = true; # übersprungene Alben beim nächsten Lauf erneut versuchen
      log = "/var/lib/beets/skipped.log";
    };

    chroma.auto = true;

    fetchart = {
      auto = true;
      minwidth = 500;
      sources = [
        "filesystem"
        "coverart"
        "itunes"
        "amazon"
        "albumart"
      ];
    };

    paths = {
      default = "$albumartist/$album%aunique{}/$disc-$track $title";
      comp = "Compilations/$album%aunique{}/$disc-$track $title";
      singleton = "Non-Album/$artist/$title";
    };
  };

  beetWrapper = pkgs.writeShellScriptBin "beet" ''
    export BEETSDIR=/var/lib/beets
    export PATH=${pkgs.chromaprint}/bin:$PATH
      exec ${pkgs.beets}/bin/beet -c ${beetsConfig} "$@"
  '';
in
{
  environment.systemPackages = [ beetWrapper ];

  systemd.tmpfiles.rules = [
    "d /var/lib/beets 0775 navidrome music -"
    "d /srv/inbox 2775 navidrome music -"
  ];

  # alle, die hochladen dürfen, in die Gruppe music
  users.users.admin.extraGroups = [ "music" ];
  # users.users.freund1.extraGroups = [ "music" ];

  systemd.services.beets-import = {
    description = "Neue Musik aus dem Inbox-Ordner mit beets importieren";
    serviceConfig = {
      Type = "oneshot";
      User = "navidrome";
      Group = "music";
      UMask = "0002"; # neue Dateien sind gruppenbeschreibbar
      ExecStart = "${beetWrapper}/bin/beet import -q /srv/inbox";
    };
  };

  systemd.timers.beets-import = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/30"; # alle 30 Minuten; nachts z. B. "04:30"
      Persistent = true;
    };
  };
}
