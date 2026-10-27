{ config, pkgs, ... }:

{
  services.stirling-pdf = {
    enable = true;
    environment = {
      SERVER_PORT = 8484;
      SERVER_ADDRESS = "127.0.0.1";
      LANGS = "de_DE";
    };
  };
}
