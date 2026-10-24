{ config, pkgs, inputs, ... }:
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
    host = "172.0.0.1";
  };
}
