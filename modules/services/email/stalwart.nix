{
  pkgs,
  config,
  TailnetName,
  Domain,
  ...
}:
let
  mtaSts = pkgs.writeTextDir ".well-known/mta-sts.txt" ''
    version: STSv1
    mode: testing
    mx: mail.hakira.de
    max_age: 86400
  '';
in
{
  environment.systemPackages = with pkgs; [
    stalwart
  ];

  sops.secrets = {
    "acme/cloudflare.env" = {
      sopsFile = ../../../secrets/cloudflare.env;
      format = "dotenv";
    };

    "stalwart/admin_password" = {
      sopsFile = ../../../secrets/singlekeys.yaml;
      key = "stalwart_admin";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "Julian.Hareng@gmail.com";
    certs."mail.hakira.de" = {
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets."acme/cloudflare.env".path;
      group = "stalwart";
      reloadServices = [ "stalwart.service" ];
    };
  };

  systemd.services.stalwart = {
    wants = [ "acme-mail.hakira.de.service" ];
    after = [ "acme-mail.hakira.de.service" ];
  };

  services.stalwart = {
    enable = true;
    openFirewall = false; # Do NOT open the firewall – Tailscale handles access
    stateVersion = "26.05";

    credentials.admin_password = config.sops.secrets."stalwart/admin_password".path;

    settings = {
      server.hostname = "mail.hakira.de";

      server.auto-ban = {
        auth.rate = "20/1d";
        abuse.rate = "35/1d";
        loiter.rate = "150/1d";
        scan.rate = "150/1d";
      };

      certificate.default = {
        cert = "%{file:/var/lib/acme/mail.hakira.de/fullchain.pem}%";
        private-key = "%{file:/var/lib/acme/mail.hakira.de/key.pem}%";
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

  services.caddy = {
    virtualHosts."hakira.${TailnetName}".extraConfig = ''
        tls {
          get_certificate tailscale
        }
      @outside not remote_ip 100.64.0.0/10 fd7a:115c:a1e0::/48
        abort @outside
        reverse_proxy 127.0.0.1:8080
    '';

    virtualHosts."mta-sts.${Domain}".extraConfig = ''
      root * ${mtaSts}
      file_server
    '';

    virtualHosts."autoconfig.${Domain}".extraConfig = ''
      @xml path /mail/config-v1.1.xml
      handle @xml {
        reverse_proxy 127.0.0.1:8080
      }
      handle {
        respond "Not found" 404
      }
    '';

    virtualHosts."autodiscover.${Domain}".extraConfig = ''
      @xml path /autodiscover/autodiscover.xml
      handle @xml {
        reverse_proxy 127.0.0.1:8080
      }
      handle {
        respond "Not found" 404
      }
    '';

  };
}
