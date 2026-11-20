{ lib, ... }:

{
  options = {
    domain = lib.mkOption {
      type = lib.types.str;
      default = "hakira.de";
      description = "Main domain for the server";
    };
    vpn-domain = lib.mkOption {
      type = lib.types.str;
      default = "pufferfish-terrapin.ts.net";
      description = "Tailscale smart dns Domain";
    };
  };

  config = { };
}
