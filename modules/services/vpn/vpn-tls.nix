{ config, ... }:
{
  sops.secrets."acme/cloudflare.env" = {
    sopsFile = ../../../secrets/cloudflare.env;
    format = "dotenv";
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "Julian.Hareng@gmail.com";
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets."acme/cloudflare.env".path;
    };
    certs.${config.vpn-domain} = {
      domain = "*.${config.vpn-domain}";
      group = config.services.caddy.group;
      reloadServices = [ "caddy.service" ];
    };
  };

  systemd.services.caddy = {
    wants = [ "acme-${config.vpn-domain}.service" ];
    after = [ "acme-${config.vpn-domain}.service" ];
  };

  services.caddy.extraConfig = ''
    (vpn_only) {
      tls /var/lib/acme/${config.vpn-domain}/fullchain.pem /var/lib/acme/${config.vpn-domain}/key.pem
      @outside not remote_ip 100.64.0.0/10 fd7a:115c:a1e0::/48
      abort @outside
    }
  '';
}
