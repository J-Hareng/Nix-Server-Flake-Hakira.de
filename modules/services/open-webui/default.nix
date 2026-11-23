{ lib, config, ... }:
#INFO PORTS: 5555 
{

  sops.secrets."webui/env" = {
    sopsFile = ../../../secrets/open-webui.env;
    format = "dotenv";
  };

  services.open-webui = {
    enable = true;
    host = "127.0.0.1";
    port = 5555;

    environmentFile = config.sops.secrets."webui/env".path;
    environment = {
      ENABLE_PERSISTENT_CONFIG = "False";

      # Login / Accounts
      WEBUI_AUTH = "True";
      ENABLE_SIGNUP = "False"; # nach Anlegen deines Accounts

      ENABLE_OPENAI_API = "False";
      ENABLE_IMAGE_GENERATION = "False";
      ENABLE_CODE_EXECUTION = "False";
      ENABLE_CODE_INTERPRETER = "False";
      ENABLE_COMMUNITY_SHARING = "False";
      ENABLE_MESSAGE_RATING = "False";
      ENABLE_EVALUATION_ARENA_MODELS = "False";
      ENABLE_CHANNELS = "False";
      ENABLE_NOTES = "False";

      ENABLE_AUTOCOMPLETE_GENERATION = "False";
      ENABLE_TAGS_GENERATION = "False";
      ENABLE_FOLLOW_UP_GENERATION = "False";

      # Websearch
      ENABLE_WEB_SEARCH = "True";
      WEB_SEARCH_ENGINE = "searxng";
      SEARXNG_QUERY_URL = "http://100.64.0.1:5554/search?q=<query>";
    };
  };

  services.caddy.virtualHosts."clank.${config.vpn-domain}".extraConfig = ''
    import vpn_only
    reverse_proxy 127.0.0.1:5555
  '';

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "open-webui"
    ];
}
