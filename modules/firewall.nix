{ ... }:
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
    ];
  };
}
