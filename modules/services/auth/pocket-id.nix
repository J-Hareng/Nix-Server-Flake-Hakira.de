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

  sops.secrets."pocket-id/encryptionkey" = {
    sopsFile = ../../../secrets/singlekeys.yaml;

    key = "pocket_id";
    owner = config.services.pocket-id.user;
    group = config.services.pocket-id.group;
  };

  services.pocket-id = {
    enable = true;

    credentials = {
      ENCRYPTION_KEY = config.sops.secrets."pocket-id/encryptionkey".path;
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
