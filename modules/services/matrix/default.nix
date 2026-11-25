{ config
, pkgs
, lib
, ...
}:
let
  matrixDomain = "matrix.${config.domain}";
in
{

  imports = [
    ./matrixrc.nix
    ./beeper-bridges.nix
  ];

  sops.secrets."continuwuity/oidc_secret" = {
    sopsFile = ../../../secrets/matrix.yaml;
    owner = config.services.matrix-continuwuity.user;
    group = config.services.matrix-continuwuity.group;
    restartUnits = [ "continuwuity.service" ];
  };


  services.matrix-continuwuity = {
    enable = true;
    package = pkgs.matrix-continuwuity_latest;

    settings.global = {
      server_name = "${matrixDomain}";
      port = [ 6167 ];
      address = [
        "::1"
        "127.0.0.1"
      ];
      max_request_size = 200000000;
      allow_public_room_directory_over_federation = true;
      allow_registration = false;
      allow_encryption = true;
      allow_federation = true;
      allow_check_password = false;
      new_user_displayname_suffix = " · ✨";
      ip_lookup_strategy = 1;
      force_migration = true;

      # PocketID (OIDC) authentication
      oauth.oidc = {
        enable = true;
        discovery_url = "https://auth.${config.domain}";
        client_id = "76e0725e-7483-43dc-9879-dc776340252e";
        client_secret_file = config.sops.secrets."continuwuity/oidc_secret".path;

        # Allows new users to automatically register when logging in via PocketID
        allow_registration = true;

        # Map claims from PocketID
        user_id_claim = "sub";
        displayname_claim = "name";
      };

      trusted_servers = [ "matrix.org" ];

      matrix_rtc.foci = [
        {
          type = "livekit";
          livekit_service_url = "https://lk-jwt.call.${matrixDomain}";
        }
      ];
    };
  };

  # Reverse proxy
  services.caddy.virtualHosts = {
    "${matrixDomain}".extraConfig = ''
      request_body {
        max_size 768MB
      }

      handle /.well-known/matrix/client {
        header Content-Type application/json
        header Access-Control-Allow-Origin *
        header Cache-Control "public, max-age=86400"
        respond `{"m.server":{"base_url":"https://${matrixDomain}"},"org.matrix.msc4048.base_url":"https://${matrixDomain}"}`
      }

      handle /.well-known/matrix/server {
        header Content-Type application/json
        respond `{"m.server":"${matrixDomain}:443"}`
      }

      handle {
        reverse_proxy 127.0.0.1:6167 {
          header_up Host {host}
          header_up X-Real-IP {remote_host}
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Proto {scheme}
        }
      }
    '';

    "s.${matrixDomain}".extraConfig = ''
      reverse_proxy 127.0.0.1:6167
    '';

    "sable.${matrixDomain}".extraConfig = ''
      forward_auth 127.0.0.1:3001 {
        uri /api/auth/caddy
        copy_headers Remote-User Remote-Email Remote-Name Remote-Groups
      }
        root * ${pkgs.runCommand "sable-web" { } ''
          mkdir -p $out
          tar -xzf ${pkgs.fetchurl {
            url = "https://git.sable.moe/SableClient/sable-next/releases/download/v26.11.4/sable-26.11.4-web.tar.gz";
            sha256 = "8d3829608fd963772e5dcfb31385afd8fe6de9fee089ef9ce076352fa2c9d612";
          }} -C $out --strip-components=1
        ''}
        file_server
        try_files {path} {path}/ /index.html
    '';
  };
}
