{ config, ... }:

{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      #ssh
      22

      #http/https
      80
      443

      #email
      25
      465
      587
      993

      #beszel
      8090
      45876
    ];

    # Tailscale
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
