{
  pkgs,
  inputs,
  TailnetName,
  ...
}:
let
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
  };
in
{
  disabledModules = [ "services/web-apps/stirling-pdf.nix" ];
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/stirling-pdf.nix"
  ];

  services.stirling-pdf = {
    enable = true;
    package = unstable.stirling-pdf;
    environment = {
      SERVER_PORT = 8484;
      SERVER_ADDRESS = "127.0.0.1";
      LANGS = "de_DE";
    };
  };

  services.caddy.virtualHosts."hakira.${TailnetName}:9112".extraConfig = ''
    encode zstd gzip
    reverse_proxy 127.0.0.1:8484
  '';
}
