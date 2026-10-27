{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    pocket-id
  ];

  services.pocket-id = {
    enable = true;

    credentials = {
      ENCRYPTION_KEY = "/etc/secrets/pocket-id/encryption-key";
    };

    settings = {
      APP_URL = "https://auth.hakira.de";
      TRUST_PROXY = true;
      HOST = "127.0.0.1";
      PORT = 9000;
    };
  };
}
