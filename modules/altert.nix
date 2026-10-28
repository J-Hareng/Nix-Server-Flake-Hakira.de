{ pkgs, config, ... }:
let
  credentials = "webhook:/${config.sops.secrets."discord-bot/cert".path}";
in
{
  sops.secrets."discord-bot/cert" = {
    sopsFile = ../secrets/singlekeys.yaml;
    key = "discord_bot_cert";
  };

  systemd.services.notify-acme-failure = {
    description = "Discord alert: certificate renewal failed";
    path = [ pkgs.curl ];
    serviceConfig = {
      Type = "oneshot";
      LoadCredential = "${credentials}";
    };
    script = ''
      curl -fsS -H 'Content-Type: application/json' \
        -d '{"content":"@everyone certificate renewal for mail.hakira.de FAILED. Check: journalctl -u acme-order-renew-mail.hakira.de.service"}' \
        "$(cat "$CREDENTIALS_DIRECTORY/webhook")"
    '';
  };
  systemd.services."acme-order-renew-mail.hakira.de".onFailure = [ "notify-acme-failure.service" ];

  systemd.services.notify-stalwart-failure = {
    description = "Discord alert: certificate renewal failed";
    path = [ pkgs.curl ];
    serviceConfig = {
      Type = "oneshot";
      LoadCredential = "${credentials}";
    };
    script = ''
      curl -fsS -H 'Content-Type: application/json' \
        -d '{"content":"@everyone STALWART IS DONW FUCK AHH !!!  Check: journalctl -u stalwart.hakira.de.service"}' \
        "$(cat "$CREDENTIALS_DIRECTORY/webhook")"
    '';
  };
  systemd.services."stalwart".onFailure = [ "notify-stalwart-failure.service" ];

  systemd.services.cert-expiry-check = {
    description = "Check TLS certificate expiry of mail.hakira.de";
    path = [
      pkgs.openssl
      pkgs.curl
      pkgs.coreutils
    ];
    serviceConfig = {
      Type = "oneshot";
      LoadCredential = "${credentials}";
    };
    script = ''
      notify() {
        curl -fsS -H 'Content-Type: application/json' \
          -d "{\"content\":\"$1\"}" "$(cat "$CREDENTIALS_DIRECTORY/webhook")"
      }
      end=$(echo | openssl s_client -connect 127.0.0.1:993 -servername mail.hakira.de 2>/dev/null \
            | openssl x509 -noout -enddate | cut -d= -f2)
      if [ -z "$end" ]; then
        notify "hakira: could not read the certificate on mail.hakira.de:993"
        exit 1
      fi
      left=$(( ( $(date -d "$end" +%s) - $(date +%s) ) / 86400 ))
      if [ "$left" -lt 20 ]; then
        notify "hakira: mail certificate expires in $left days"
        exit 1
      fi
    '';
  };

  systemd.timers.cert-expiry-check = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
