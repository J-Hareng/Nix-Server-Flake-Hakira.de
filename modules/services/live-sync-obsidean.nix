{ config, pkgs, ... }:

{
  # CouchDB aktivieren
  services.couchdb.enable = true;

  # CouchDB 3.x verwenden (Standard in aktuellen NixOS-Versionen)
  services.couchdb.package = pkgs.couchdb3;

  # Die Datenbank soll nur lokal lauschen; der Reverse-Proxy übernimmt die Außenwelt
  services.couchdb.bindAddress = "127.0.0.1";

  # Admin-Benutzer und Passwort festlegen
  # WICHTIG: Passwort in einer echten Konfiguration aus einer Secret-Datei beziehen!
  services.couchdb.adminUser = "admin";
  services.couchdb.adminPass = /etc/secrets/LiveSync/adminkey;

  # Zusätzliche CouchDB-Konfiguration (CORS, Limits etc.)
  # Diese Einstellungen sind entscheidend für die Kommunikation mit Obsidian.
  services.couchdb.extraConfig = ''
    [chttpd]
    enable_cors = true
    require_valid_user = true

    [cors]
    credentials = true
    origins = app://obsidian.md,capacitor://localhost,http://localhost
    methods = GET, PUT, POST, HEAD, DELETE
    headers = accept, authorization, content-type, origin, referer, x-csrf-token

    [chttpd_auth]
    require_valid_user = true

    [httpd]
    max_http_request_size = 4294967296
  '';
}
