{
  inputs,
  Domain,
  config,
  ...
}:

{
  imports = [ inputs.degoog.nixosModules.default ];

  sops.secrets."degoog/env" = {
    sopsFile = ../../secrets/degoog.env;
    format = "dotenv";
  };

  services.degoog = {
    enable = true;

    environmentFile = config.sops.secrets."degoog/env".path;
    environment = {
      PORT = "4444";
      DEGOOG_PUBLIC_INSTANCE = false;
      DEGOOG_BIND_ADDRESS = "127.0.0.1";
      DEGOOG_BASE_URL = "https://search.${Domain}";
      DEGOOG_DISTRUST_PROXY = false;
    };
  };

  services.caddy.virtualHosts."search.${Domain}".extraConfig = ''
    forward_auth 127.0.0.1:3001 {
      uri /api/auth/caddy
      copy_headers Remote-User Remote-Email Remote-Name Remote-Groups
    }
    reverse_proxy http://127.0.0.1:4444
  '';
}
