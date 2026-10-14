{ config, pkgs, ... }:

{

  services.couchdb = {
    enable = true;
    package = pkgs.couchdb3;
    bindAddress = "127.0.0.1";

    extraConfig = {
      admins = {
        admin = "-pbkdf2-59d4fbf0d0c5c61d25b651932eae64c6ce33bcb625b1cd5f21da6b98cf74f588,4f50816b988112da5430774f53d28315,10000";
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
