{ pkgs
, config
, ...
}:
#INFO PORTS: 8080
let
  adminHost = "stalwart.${config.vpn-domain}";
  mailHost = "mail.${config.domain}";

  mtaSts = pkgs.writeTextDir ".well-known/mta-sts.txt" ''
    version: STSv1
    mode: testing
    mx: mail.hakira.de
    max_age: 86400
  '';

  xmlOnly = path: ''
    @xml path ${path}
    handle @xml {
      reverse_proxy 127.0.0.1:8080
    }
    handle {
      respond "Not found" 404
    }
  '';
in
{
  sops.secrets."stalwart/admin_password" = {
    sopsFile = ../../../secrets/singlekeys.yaml;
    key = "stalwart_admin";
  };

  security.acme.certs.${mailHost} = {
    group = "stalwart";
    reloadServices = [ "stalwart.service" ];
  };

  systemd.services.stalwart = {
    wants = [ "acme-${mailHost}.service" ];
    after = [ "acme-${mailHost}.service" ];
  };

  services.stalwart = {
    enable = true;
    openFirewall = false;
    stateVersion = "26.05";

    credentials.admin_password = config.sops.secrets."stalwart/admin_password".path;

    settings = {
      server.hostname = "mail.${config.domain}";

      server.auto-ban = {
        auth.rate = "20/1d";
        abuse.rate = "35/1d";
        loiter.rate = "150/1d";
        scan.rate = "150/1d";
      };

      certificate.default = {
        cert = "%{file:/var/lib/acme/${mailHost}/fullchain.pem}%";
        private-key = "%{file:/var/lib/acme/${mailHost}/key.pem}%";
        default = true;
      };

      server.listener = {
        smtp = {
          bind = [ "0.0.0.0:25" ];
          protocol = "smtp";
        };
        submission = {
          bind = [ "0.0.0.0:587" ];
          protocol = "smtp";
        };
        submissions = {
          bind = [ "0.0.0.0:465" ];
          protocol = "smtp";
          tls.implicit = true;
        };
        imaps = {
          bind = [ "0.0.0.0:993" ];
          protocol = "imap";
          tls.implicit = true;
        };
        management = {
          bind = [ "127.0.0.1:8080" ];
          protocol = "http";
        };
      };
      authentication.fallback-admin = {
        user = "admin";
        secret = "%{file:/run/credentials/stalwart.service/admin_password}%";
      };
    };
  };

  services.caddy.virtualHosts = {
    "${adminHost}".extraConfig = ''
      import vpn_only
      reverse_proxy 127.0.0.1:8080
    '';

    "mta-sts.${config.domain}".extraConfig = ''
      root * ${mtaSts}
      file_server
    '';

    "autoconfig.${config.domain}".extraConfig = xmlOnly "/mail/config-v1.1.xml";
    "autodiscover.${config.domain}".extraConfig = xmlOnly "/autodiscover/autodiscover.xml";
  };
}
