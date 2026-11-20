{ pkgs
, config
, ...
}:
#INFO PORTS: 8090
{
  environment.systemPackages = [
    pkgs.beszel
  ];

  sops.secrets."beszel/env" = {
    sopsFile = ../../secrets/beszel.env;
    format = "dotenv";
  };

  services.beszel.hub = {
    enable = true;
    port = 8090;
    environment = {

      # USER_CREATION = "true";
      DISABLE_PASSWORD_AUTH = "true";
    };

  };

  services.beszel.agent = {
    enable = true;

    environmentFile = config.sops.secrets."beszel/env".path;
    smartmon.enable = true;
  };

  services.caddy.virtualHosts."stats.${config.domain}".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString config.services.beszel.hub.port}
  '';

}
