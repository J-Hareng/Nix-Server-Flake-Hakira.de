{ pkgs, config, ... }:
{
  environment.systemPackages = with pkgs; [
    caddy
  ];

  services.caddy = {
    enable = true;
    virtualHosts."auth.hakira.de".extraConfig = ''
      reverse_proxy http://127.0.0.1:9000
    '';
    virtualHosts."vault.hakira.de".extraConfig = ''
      encode zstd gzip
      reverse_proxy http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}
    '';
  };
}
