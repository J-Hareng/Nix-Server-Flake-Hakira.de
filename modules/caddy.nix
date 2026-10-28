{ config, pkgs, ... }:
let
  tailnetName = "pufferfish-terrapin.ts.net";
  domain = "hakira.de";
in
{

  services.caddy = {
    enable = true;

    virtualHosts."search.${domain}".extraConfig = ''
      forward_auth 127.0.0.1:3001 {
        uri /api/auth/caddy
        copy_headers Remote-User Remote-Email Remote-Name Remote-Groups
      }
      reverse_proxy http://127.0.0.1:4444
    '';

    virtualHosts."immich.${domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:2283
    '';

    virtualHosts."media.${domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:4533
    '';

    virtualHosts."upload.${domain}".extraConfig = ''
      reverse_proxy http://127.0.0.1:3923
    '';

    #Tailnet

    virtualHosts."hakira.${tailnetName}:9112".extraConfig = ''
            encode zstd gzip
            reverse_proxy 127.0.0.1:8484
          '';

    virtualHosts."hakira.${tailnetName}:8443".extraConfig = ''
      tls {
        get_certificate tailscale
      }
      @outside not remote_ip 100.64.0.0/10 fd7a:115c:a1e0::/48
      abort @outside
      encode zstd gzip
      header {
        X-Content-Type-Options nosniff
        X-Frame-Options SAMEORIGIN
        Referrer-Policy same-origin
      }
      request_body {
        max_size 40MB
      }
      root * ${config.services.roundcube.package}/public_html
      php_fastcgi unix/${config.services.phpfpm.pools.roundcube.socket}
      file_server
    '';
    # virtualHosts."stats_agents.hakira.${tailnetName}".extraConfig = ''
    #   tls {
    #     get_certificate tailscale
    #   }
    #   reverse_proxy 127.0.0.1:45876
    # '';
  };
}
