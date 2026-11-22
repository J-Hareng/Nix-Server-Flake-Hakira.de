{ pkgs
, config
, ...
}:

#INFO PORTS: 8443 
{
  environment.systemPackages = with pkgs; [
    roundcube
  ];

  services.roundcube = {
    enable = true;
    hostName = "webmail.${config.vpn-domain}";
    configureNginx = false;
    maxAttachmentSize = 25;
    extraConfig = ''
      $config['imap_host'] = "ssl://mail.hakira.de:993";
      $config['smtp_host'] = "ssl://mail.hakira.de:465";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
      $config['product_name'] = "Hakira Mail";
      $config['skin'] = "elastic";
      $config['session_lifetime'] = 30;
      $config['ip_check'] = true;
    '';
  };

  services.phpfpm.pools.roundcube.settings = {
    "listen.owner" = "caddy";
    "listen.group" = "caddy";
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 8443 ];

  services.caddy.virtualHosts."hakira.${config.vpn-domain}:8443".extraConfig = ''
    import vpn_only
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

}
