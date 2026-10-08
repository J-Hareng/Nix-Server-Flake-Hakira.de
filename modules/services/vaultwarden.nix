{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vaultwarden
  ];
  services.vaultwarden = {
    enable = true;
    backupDir = "/etc/backup/vaultwarden-backup";
    environmentFile = "/etc/secrets/vaultwarden/vaultwarden.env";
    config = {
      DOMAIN = "https://vault.hakira.de";

      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      ROCKET_LOG = "critical";

      # --- Email settings (Optional but recommended for invitations) ---
      # If you have a local mail server, you can configure it like this:
      # SMTP_HOST = "127.0.0.1";
      # SMTP_PORT = 25;
      # SMTP_SSL = false;
      # SMTP_FROM = "admin@vaultwarden.example.com";
      # SMTP_FROM_NAME = "example.com Vaultwarden";
    };
  };
}
