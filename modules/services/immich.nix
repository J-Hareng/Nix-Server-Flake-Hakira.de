{ pkgs
, inputs
, config
, ...
}:
#INFO PORTS: 2283
let
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true; # only if you need it
  };
in
{
  disabledModules = [ "services/web-apps/immich.nix" ];
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/immich.nix"
  ];

  services.immich = {
    enable = true;
    package = unstable.immich;
    port = 2283;
    host = "127.0.0.1";
    mediaLocation = "/srv/immich";
    environment = {
      IMMICH_TRUSTED_PROXIES = "127.0.0.1";
    };
  };

  services.caddy.virtualHosts."immich.${config.domain}".extraConfig = ''
    reverse_proxy http://127.0.0.1:2283
  '';
}
