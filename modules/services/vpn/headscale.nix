{ config, pkgs, ... }:
#INFO PORTS: 8085
let
  hsHost = "hs.${config.domain}";
  hsPort = 8085;

  policy = pkgs.writeText "headscale-acl.json" (builtins.toJSON {
    groups = {
      "group:admin" = [ "julian_hareng@" ]; # check the real name with `headscale users list`
      "group:friends" = [ ]; # add friends after their first login
    };
    tagOwners = {
      "tag:server" = [ "group:admin" ];
      "tag:backup" = [ "group:admin" ];
    };
    acls = [
      { action = "accept"; src = [ "group:admin" ]; dst = [ "*:*" ]; }

      # restic: server -> Pi over SSH/SFTP
      { action = "accept"; src = [ "tag:server" ]; dst = [ "tag:backup:22" ]; }
      # friends get explicit rules only, e.g.:

      # { action = "accept"; src = [ "group:friends" ]; dst = [ "tag:server:<port>" ]; }
    ];
  });
in
{
  sops.secrets = {
    "headscale/oidc_secret" = {
      sopsFile = ../../../secrets/singlekeys.yaml;
      key = "headscale_oidc";
      owner = config.services.headscale.user;
      group = config.services.headscale.group;
    };
  };

  users.users.admin.extraGroups = [ "headscale" ];

  services.headscale = {
    enable = true;
    address = "127.0.0.1";
    port = hsPort;

    settings = {
      server_url = "https://${hsHost}";

      dns = {
        magic_dns = true;
        base_domain = config.vpn-domain;
        override_local_dns = false;
      };

      derp = {
        server = {
          enabled = true;
          region_id = 999;
          region_code = "hakira";
          region_name = "hakira DERP";
          stun_listen_addr = "0.0.0.0:3478";
          ipv4 = "136.243.51.143";
        };
        urls = [ ];
      };

      logtail.enabled = false;

      policy = { mode = "file"; path = policy; };

      oidc = {
        issuer = "https://auth.${config.domain}";
        client_id = "e1f54f7e-2a91-4ed0-a3a3-2a6be9cfbc7f";
        client_secret_path = config.sops.secrets."headscale/oidc_secret".path;
        pkce.enabled = true;
        # Pocket ID and Headscale share a host: don't let a Pocket ID outage stop Headscale
        only_start_if_oidc_is_available = false;
      };
    };
  };

  services.caddy.virtualHosts.${hsHost}.extraConfig = ''
    reverse_proxy 127.0.0.1:${toString hsPort}
  '';
}
