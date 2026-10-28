{
  pkgs,
  inputs,
  Domain,
  config,
  ...
}:
let
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in
{
  sops.secrets."stirling-pdf/env" = {
    sopsFile = ../../secrets/stirling.env;
    format = "dotenv";
  };

  disabledModules = [ "services/web-apps/stirling-pdf.nix" ];
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/stirling-pdf.nix"
  ];

  services.stirling-pdf = {
    enable = true;
    package = unstable.stirling-pdf;
    environmentFile = config.sops.secrets."stirling-pdf/env".path;
    environment = {
      SERVER_PORT = 8484;
      SERVER_ADDRESS = "127.0.0.1";
      LANGS = "de_DE";

      SECURITY_ENABLELOGIN = "true";
      SECURITY_OAUTH2_ENABLED = "true";
      SECURITY_OAUTH2_PROVIDER = "pocket-id";
      SECURITY_OAUTH2_ISSUER = "https://auth.${Domain}";
      SECURITY_OAUTH2_SCOPES = "openid, profile, email";
      SECURITY_OAUTH2_USEASUSERNAME = "email";
      SECURITY_OAUTH2_AUTOCREATEUSER = "true";
    };
  };

  services.caddy."pdf.${Domain}".extraConfig = ''
    encode zstd gzip
    reverse_proxy 127.0.0.1:8484
  '';
}
