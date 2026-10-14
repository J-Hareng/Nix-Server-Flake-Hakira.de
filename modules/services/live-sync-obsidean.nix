{ config, pkgs, ... }:

{

  services.couchdb = {
    enable = true;
    package = pkgs.couchdb3;
    bindAddress = "127.0.0.1";

    extraConfig = {
      admins = {
        admin = "-pbkdf2-b1251b46f170db55c36be6b1e9b60cb5ecd91d5c,3bbcc45e3c68ffec9e56ee3d9f1bedd8,10000";
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
