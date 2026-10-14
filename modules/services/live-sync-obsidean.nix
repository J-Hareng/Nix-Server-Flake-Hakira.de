{ config, pkgs, ... }:

{
  services.couchdb.enable = true;

  services.couchdb.package = pkgs.couchdb3;

  services.couchdb.bindAddress = "127.0.0.1";

  services.couchdb.adminUser = "admin";
  services.couchdb.adminPass = /etc/secrets/LiveSync/adminkey;

  services.couchdb.extraConfig = {
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
}
