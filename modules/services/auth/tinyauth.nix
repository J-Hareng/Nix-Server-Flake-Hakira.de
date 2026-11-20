{ config, ... }:
#INFO PORTS: 3001
{
  sops.secrets."tinyauth/env" = {
    sopsFile = ../../../secrets/tinyauth.env;
    format = "dotenv";
  };

  services.tinyauth = {
    enable = true;
    environmentFile = config.sops.secrets."tinyauth/env".path;

    settings = {
      APPURL = "https://tinyauth.${config.domain}";
      SERVER_PORT = 3001;
      SERVER_ADDRESS = "127.0.0.1";
    };
  };

  services.caddy.virtualHosts."tinyauth.${config.domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:3001
  '';
}
