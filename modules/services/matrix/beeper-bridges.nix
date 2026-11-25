{ config, inputs, pkgs, ... }:
let
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  matrixDomain = "matrix.${config.domain}";
  adminMxid = "@hakira:${matrixDomain}";

  homeserver = {
    address = "http://127.0.0.1:6167";
    domain = matrixDomain; # must match server_name
  };
in
{
  services.mautrix-whatsapp.package = pkgs-unstable.mautrix-whatsapp.override { withGoolm = true; };
  services.mautrix-signal.package = pkgs-unstable.mautrix-signal.override { withGoolm = true; };

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
