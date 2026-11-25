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

  ### WHATSAPP bridge
  services.mautrix-whatsapp.package = pkgs-unstable.mautrix-whatsapp.override { withGoolm = true; };
  sops.secrets."mautrix/whatsapp_pickle_key".sopsFile = ../../../secrets/matrix.yaml;
  sops.templates."mautrix-whatsapp.env" = {
    content = ''
      MAUTRIX_WHATSAPP_PICKLE_KEY=${config.sops.placeholder."mautrix/whatsapp_pickle_key"}
    '';
    restartUnits = [ "mautrix-whatsapp.service" ];
  };

  services.mautrix-whatsapp = {
    environmentFile = config.sops.templates."mautrix-whatsapp.env".path;
    enable = true;
    encryption = {
      allow = true;
      default = true;
      msc4190 = true;
      self_sign = true;
      pickle_key = "$MAUTRIX_WHATSAPP_PICKLE_KEY";
    };

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
    };
  };


  ### SIGNAL bridge
  services.mautrix-signal.package = pkgs-unstable.mautrix-signal.override { withGoolm = true; };
  sops.secrets."mautrix/signal_pickle_key".sopsFile = ../../../secrets/matrix.yaml;
  sops.templates."mautrix-signal.env" = {
    content = ''
      MAUTRIX_SIGNAL_PICKLE_KEY=${config.sops.placeholder."mautrix/signal_pickle_key"}
    '';
    restartUnits = [ "mautrix-signal.service" ];
  };

  services.mautrix-signal = {
    environmentFile = config.sops.templates."mautrix-signal.env".path;
    enable = true;
    encryption = {
      allow = true;
      default = true;
      msc4190 = true;
      self_sign = true;
      pickle_key = "$MAUTRIX_SIGNAL_PICKLE_KEY";
    };
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
