{ config, nixpkgs-unstable, ... }:
let
  matrixDomain = "matrix.${config.domain}";
  # Your MXID. With OIDC and user_id_claim = "sub", this is likely
  # a UUID-style localpart, so check it in Sable.
  #YOUR_LOCALPART
  adminMxid = "@hakira:${matrixDomain}";

  homeserver = {
    address = "http://127.0.0.1:6167";
    domain = matrixDomain; # must match server_name
  };
in
{
  services.mautrix-whatsapp.package = nixpkgs-unstable.mautrix-whatsapp;

  services.mautrix-whatsapp = {
    enable = true;
    settings = {
      inherit homeserver;
      appservice = {
        address = "http://127.0.0.1:29318";
        hostname = "127.0.0.1";
        port = 29318;
      };
      bridge.permissions = {
        "*" = "relay";
        "${matrixDomain}" = "user";
        "${adminMxid}" = "admin";
      };
      # database defaults to SQLite, which is fine for one user
    };
  };

  services.mautrix-signal = {
    enable = true;
    settings = {
      inherit homeserver;
      appservice = {
        address = "http://127.0.0.1:29328";
        hostname = "127.0.0.1";
        port = 29328;
      };
      bridge.permissions = {
        "*" = "relay";
        "${matrixDomain}" = "user";
        "${adminMxid}" = "admin";
      };
    };
  };

  # Keep the bridges from starting before the homeserver
  systemd.services.mautrix-whatsapp = {
    after = [ "continuwuity.service" ];
    wants = [ "continuwuity.service" ];
  };
  systemd.services.mautrix-signal = {
    after = [ "continuwuity.service" ];
    wants = [ "continuwuity.service" ];
  };
}
