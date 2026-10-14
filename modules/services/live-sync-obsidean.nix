{ config, pkgs, ... }:

{

  services.couchdb = {
    enable = true;
    package = pkgs.couchdb3;
    bindAddress = "127.0.0.1";

    extraConfig = {
      admins = {
        admin = "-pbkdf2-797be09c3c86bd06ba284544958f88ea06543c9101296d772e4e027b8174d85c";
      };
      chttpd = {
        enable_cors = true;
        require_valid_user = true;
      };
      cors = {
        credentials = true;
        origins = "app://obsidian.md,capacitor://localhost,http://localhost";
        methods = "GET, PUT, POST, HEAD, DELETE";
        headers = "accept, authorization, content-type, origin, referer, x-csrf-token";
      };

      chttpd_auth = {
        require_valid_user = true;
      };

      httpd = {
        max_http_request_size = 4294967296;
      };
    };
  };

}
