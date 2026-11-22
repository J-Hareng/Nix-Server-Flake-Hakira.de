{ config }:
let
  d = config.vpn-domain;
  ip = "100.64.0.3";
in
{
  services.headscale.settings.dns.extra_records = [
    { name = "stalwart.${d}"; type = "A"; value = ip; }
    { name = "webmail.${d}"; type = "A"; value = ip; }
    { name = "reactive-resume.${d}"; type = "A"; value = ip; }
    { name = "clank.${d}"; type = "A"; value = ip; }
  ];

}
