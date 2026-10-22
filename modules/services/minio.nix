{ config, pkgs, lib, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [
    "minio-2025-10-15T17-29-55Z"
  ];

  services.minio = {
    enable = true;
    rootCredentialsFile = "/etc/secrets/minio/root-credentials";
    dataDir = [ "/var/lib/minio/data" ];
    listenAddress = "127.0.0.1:9010";   # S3 API
    consoleAddress = "127.0.0.1:9011";  # Web console
  };

  # 3. Idempotent bucket creation on every boot
  systemd.services.minio-bucket-init = {
    description = "Initialize MinIO buckets";
    after = [ "minio.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      until ${pkgs.curl}/bin/curl -sf http://127.0.0.1:9000/minio/health/live > /dev/null 2>&1; do
        echo "Waiting for MinIO..."
        sleep 1
      done

      ${pkgs.minio-client}/bin/mc alias set local http://127.0.0.1:9000 \
        "$(grep MINIO_ROOT_USER /etc/secrets/minio/root-credentials | cut -d= -f2)" \
        "$(grep MINIO_ROOT_PASSWORD /etc/secrets/minio/root-credentials | cut -d= -f2)" || true

      ${pkgs.minio-client}/bin/mc mb --ignore-existing local/my-test-bucket || true
    '';
  };
}
