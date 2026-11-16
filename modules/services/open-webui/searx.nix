{ config, ... }:
{
  sops.secrets."searx/key" = {
    sopsFile = ../../../secrets/singlekeys.yaml;
    key = "searx_secret_key";
  };

  services.searx = {
    enable = true;
    settings = {
      server = {
        port = 5554;
        bind_address = "127.0.0.1";
        secret_key = config.sops.secrets."searx/key".path;

      };
      search.formats = [ "html" "json" ];
      engines = [
        # blockierte abschalten
        { name = "brave"; disabled = true; }
        { name = "duckduckgo"; disabled = true; }
        { name = "startpage"; disabled = true; }
        { name = "google"; disabled = true; }

        # allgemeine Websuche
        { name = "bing"; disabled = false; }
        { name = "mojeek"; disabled = false; }

        # Programmieren
        { name = "stackoverflow"; disabled = false; }
        { name = "github"; disabled = false; }
        { name = "mdn"; disabled = false; }
        { name = "askubuntu"; disabled = false; }
        { name = "superuser"; disabled = false; }
        { name = "arch linux wiki"; disabled = false; }
        { name = "hackernews"; disabled = false; }
        { name = "wikipedia"; disabled = false; }

        # unnötige, die nur Fehler im Log machen
        { name = "ahmia"; disabled = true; }
        { name = "torch"; disabled = true; }
        { name = "radio browser"; disabled = true; }
        { name = "wikidata"; disabled = true; }
      ];
    };
  };

}
