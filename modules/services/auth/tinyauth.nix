{ ... }:
{
  virtualisation.oci-containers.containers.tinyauth = {
    image = "ghcr.io/steveiliop56/tinyauth:v4";
    environmentFiles = [ "/etc/secrets/tinyauth/tinyauth.env" ];
    environment = {
      SERVER_PORT = "3001";
      SERVER_ADDRESS = "127.0.0.1";
    };
    extraOptions = [ "--network=host" ];
  };
}
