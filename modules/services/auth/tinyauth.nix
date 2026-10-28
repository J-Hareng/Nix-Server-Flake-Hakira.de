{ config, ... }:
{

  sops.secrets."tinyauth/env" = {
    sopsFile = ../../../secrets/tinyauth.env;
    format = "dotenv";
  };

  services.tinyauth = {
    enable = true;
    environmentFile = config.sops.secrets."tinyauth/env".path;

    settings = {
      APPURL = "https://tinyauth.hakira.de";
      SERVER_PORT = 3001;
      SERVER_ADDRESS = "127.0.0.1";
    };
  };
}
