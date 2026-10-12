{ pkgs, ... }:
let
  tailnetName = "pufferfish-terrapin.ts.net";
in
{
  environment.systemPackages = with pkgs; [
    roundcube
  ];

  services.roundcube = {
    enable = true;
    hostName = "hakira.${tailnetName}";
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
}
