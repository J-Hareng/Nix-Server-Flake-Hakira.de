{
  pkgs,
  Domain,
  config,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    pocket-id
  ];

  sops.secrets."pocket-id/encryption-key" = {
    sopsFile = ../../../secrets/singlekeys.env;
    format = "dotenv";
    key = "pocket-id";

  };

  services.pocket-id = {
    enable = true;

    credentials = {
      ENCRYPTION_KEY = config.sops.secrets."pocket-id/encryption-key".data;
    };

    settings = {
      APP_URL = "https://auth.hakira.de";
      TRUST_PROXY = true;
      HOST = "127.0.0.1";
      PORT = 9000;
    };
  };

  services.caddy.virtualHosts."auth.${Domain}".extraConfig = ''
    reverse_proxy http://127.0.0.1:9000
  '';
}
