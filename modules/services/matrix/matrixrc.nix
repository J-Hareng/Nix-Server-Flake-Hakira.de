{ lib
, config
, ...
}:

let

  matrixDomain = "matrix.${config.domain}";

  livekitDomain = "livekit.call.${matrixDomain}";
  lkJwtServiceDomain = "lk-jwt.call.${matrixDomain}";
in
{
  sops.secrets."livekit/keys" = {
    sopsFile = ../../../secrets/matrix.yaml;
    restartUnits = [ "livekit.service" "lk-jwt-service.service" ];
  };


  services.livekit = {
    enable = true;
    openFirewall = true;


    keyFile = config.sops.secrets."livekit/keys".path;

    settings = {
      port = 7880;
      bind_addresses = [ "127.0.0.1" ];
      rtc = {
        port_range_start = 50000;
        port_range_end = 51000;
        use_external_ip = true;
        node_ip = "136.243.51.143";
      };
      room.auto_create = false;
    };
  };

  services.lk-jwt-service = {
    enable = true;
    livekitUrl = "wss://${livekitDomain}";
    keyFile = config.services.livekit.keyFile;
    port = 8082;
  };

  systemd.services.lk-jwt-service.environment.LIVEKIT_FULL_ACCESS_HOMESERVERS =
    "${matrixDomain}";

  systemd.services = {
    livekit.serviceConfig.Restart = lib.mkForce "always";
    lk-jwt-service.serviceConfig.Restart = lib.mkForce "always";
  };

  services.caddy.virtualHosts = {
    "${livekitDomain}".extraConfig = ''
      reverse_proxy 127.0.0.1:7880
    '';

    "${lkJwtServiceDomain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString config.services.lk-jwt-service.port}
    '';
  };
}
