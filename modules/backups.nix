{ config }: {

  sops.secrets."restic/password" = {
    sopsFile = ../secrets/restic.yaml;
    key = "password";
  };

  sops.secrets."restic/ssh_key" = {
    sopsFile = ../secrets/restic.yaml;
    key = "ssh_key";
  };

  sops.secrets."restic/pi_host" = {
    sopsFile = ../secrets/restic.yaml;
    key = "pi_host";
  };

  sops.secrets."restic/pi_user" = {
    sopsFile = ../secrets/restic.yaml;
    key = "pi_user";
  };

  sops.templates."restic-ssh-config".content = ''
    Host pi-backup
      HostName ${config.sops.placeholder."restic/pi_host"}
      User ${config.sops.placeholder."restic/pi_user"}
      IdentityFile ${config.sops.secrets."restic/ssh_key".path}
      IdentitiesOnly yes
      StrictHostKeyChecking accept-new
  '';

  services.restic.backups.pi = {
    initialize = true;
    repository = "sftp:pi-backup:/mnt/backup/restic";
    passwordFile = config.sops.secrets."restic/password".path;
    extraOptions = [
      "sftp.command='ssh -F ${config.sops.templates."restic-ssh-config".path} pi-backup -s sftp'"
    ];

    paths = [
      # what you asked for
      "/srv/immich"
      "/var/lib/vaultwarden"
      "/etc/backup/vaultwarden-backup"
      "/var/lib/stalwart"
      "/var/lib/pocket-id"
      "/var/lib/couchdb"
      "/var/backup/postgresql"

      # small and worth keeping
      "/var/lib/reactive-resume"
      "/var/lib/roundcube"
      "/var/lib/navidrome"
      "/var/lib/beets"
      "/var/lib/open-webui"
      "/home/admin"
    ];

    exclude = [
      "/srv/immich/thumbs"
      "/srv/immich/encoded-video"
      "/var/lib/vaultwarden/db.sqlite3*"
      "/var/lib/vaultwarden/icon_cache"
      "**/.cache"
    ];
    backupPrepareCommand = "${pkgs.systemd}/bin/systemctl stop stalwart.service";

    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
    };

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];

    systemd.services.restic-backups-pi.serviceConfig.ExecStopPost =
      "-${pkgs.systemd}/bin/systemctl start stalwart.service";
  };
}
