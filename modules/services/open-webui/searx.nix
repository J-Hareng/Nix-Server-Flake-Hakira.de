{ config, ... }:
{
  sops.secrets."searx/key" = {
    sopsFile = ../secrets/singlekeys.yaml;
    key = "searx_secret_key";
  };

  services.searx = {
    enable = true;
    settings = {
      server = {
        port = 5554;
        bind_address = "127.0.0.1";
        secret_key = config.sops.secrets."searx/key".path;
      };
      search.formats = [ "html" "json" ];
    };
  };

}
