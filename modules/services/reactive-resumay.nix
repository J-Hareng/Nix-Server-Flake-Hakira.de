{
  config,
  TailnetName,
  ...
}:
let
  appUrl = "https://hakira.${TailnetName}:8444";
in
{
  sops.secrets."reactive-resume/env" = {
    sopsFile = ../../secrets/reactive_resume.env;
    format = "dotenv";
  };

  # --- PostgreSQL: nur localhost (Standard), Passwort-Auth ---
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "reactive_resume" ];
    ensureUsers = [
      {
        name = "reactive_resume";
        ensureDBOwnership = true;
      }
    ];
  };

  systemd.services.reactive-resume-db-password = {
    description = "Set Reactive Resume DB password";
    after = [
      "postgresql.service"
      "postgresql-setup.service"
    ];
    requires = [
      "postgresql.service"
      "postgresql-setup.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "postgres";
      EnvironmentFile = config.sops.secrets."reactive_resume/env".path;
    };
    script = ''
      ${config.services.postgresql.package}/bin/psql -v ON_ERROR_STOP=1 \
        -c "ALTER USER reactive_resume PASSWORD '$DB_PASSWORD'"
    '';
  };

  services.postgresqlBackup = {
    enable = true;
    databases = [ "reactive_resume" ];
  };

  virtualisation.podman.enable = true;
  virtualisation.oci-containers = {
    backend = "podman";
    containers.reactive-resume = {
      image = "ghcr.io/reactive-resume/reactive-resume:v6.0.4";
      environment = {
        APP_URL = appUrl;
        STORAGE_BACKEND = "local";
        OAUTH_PROVIDER_NAME = "Pocket ID";
        OAUTH_DISCOVERY_URL = "https://auth.hakira.de/.well-known/openid-configuration";
      };
      environmentFiles = [ config.sops.secrets."reactive_resume/env".path ];
      volumes = [ "/var/lib/reactive-resume:/app/data" ];
      extraOptions = [
        "--network=host"
        "--security-opt=no-new-privileges"
      ];
    };
  };

  systemd.services.podman-reactive-resume = {
    after = [ "reactive-resume-db-password.service" ];
    requires = [ "reactive-resume-db-password.service" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/reactive-resume 0750 1000 1000 -"
  ];

  services.caddy.virtualHosts."${appUrl}".extraConfig = ''
    tls {
      get_certificate tailscale
    }
    @outside not remote_ip 100.64.0.0/10 fd7a:115c:a1e0::/48
    abort @outside
    encode zstd gzip
    reverse_proxy 127.0.0.1:3000
  '';
  # Port nur über das Tailscale-Interface erreichbar
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 8444 ];
}
