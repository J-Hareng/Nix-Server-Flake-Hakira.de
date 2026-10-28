{
  pkgs,
  config,
  Domain,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    vaultwarden
  ];

  sops.secrets."vaultwarden/env" = {
    sopsFile = ../../secrets/vaultwarden.env;
    format = "dotenv";
  };

  services.vaultwarden = {
    enable = true;
    backupDir = "/etc/backup/vaultwarden-backup";
    environmentFile = config.sops.secrets."vaultwarden/env".path;
    config = {
      DOMAIN = "https://vault.${Domain}";

      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      ROCKET_LOG = "critical";
    };
  };

  services.caddy.virtualHosts."vault.${Domain}".extraConfig = ''
    encode zstd gzip
    reverse_proxy http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}
  '';
}
