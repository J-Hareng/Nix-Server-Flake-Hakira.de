{ config, pkgs, lib, ... }:
{
  services.minio = {
    enable = true;

    rootCredentialsFile = "/etc/secrets/minio/root-credentials";

    dataDir = [ "/var/lib/minio/data" ];

    listenAddress = "127.0.0.1:9000"; # S3 API
    consoleAddress = "127.0.0.1:9001"; # Web Console
  };

  systemd.services.minio-bucket-init = {
    description = "Initialize MinIO buckets";
    after = [ "minio.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Wait for the MinIO S3 API to become healthy
      until ${pkgs.curl}/bin/curl -sf http://127.0.0.1:9000/minio/health/live > /dev/null 2>&1; do
        echo "Waiting for MinIO to be ready..."
        sleep 1
      done

      # Configure the MinIO client (mc) with the root credentials
      ${pkgs.minio-client}/bin/mc alias set local http://127.0.0.1:9000 \
        "$(grep MINIO_ROOT_USER /etc/secrets/minio/root-credentials | cut -d= -f2)" \
        "$(grep MINIO_ROOT_PASSWORD /etc/secrets/minio/root-credentials | cut -d= -f2)" || true

      # Create your desired buckets (idempotent, safe to run repeatedly)
      ${pkgs.minio-client}/bin/mc mb --ignore-existing local/my-test-bucket || true
      # Add more buckets here:
      # ${pkgs.minio-client}/bin/mc mb --ignore-existing local/another-bucket || true

      echo "MinIO bucket initialization complete."
    '';
  };
}
