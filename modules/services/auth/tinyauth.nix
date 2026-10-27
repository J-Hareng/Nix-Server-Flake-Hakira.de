{ ... }:
{
  services.tinyauth = {
    enable = true;
    environmentFile = "/etc/secrets/tinyauth.env";
  };
}
