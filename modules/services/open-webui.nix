{ Domain, TailnetName, config, ... }:
{
  sops.secrets."webui/env" = {
    sopsFile = ../../secrets/open-webui.env;
    format = "dotenv";
  };

  services.open-webui = {
    enable = true;
    host = "127.0.0.1";
    port = 5555;

    environmentFile = config.sops.secrets."webui/env".path;
  };


  virtualHosts."hakira.${TailnetName}".extraConfig = ''
      tls {
        get_certificate tailscale
      }
    @outside not remote_ip 100.64.0.0/10 fd7a:115c:a1e0::/48
      abort @outside
      reverse_proxy 127.0.0.1:5555
  '';

}
