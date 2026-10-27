{ ... }:
{
  services.tinyauth = {
    enable = true;
    environmentFile = "/etc/secrets/tinyaut/tinyauth.env"; # port: 3001

    settings = {
      APPURL = "https://tinyauth.hakira.de";
      SERVER_PORT = 3001;
      SERVER_ADDRESS = "127.0.0.1";
    };
  };
}
