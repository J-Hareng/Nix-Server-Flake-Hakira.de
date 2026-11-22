{ ...
}:
{
  imports = [
    ./tailscale.nix
    ./headscale.nix
    ./vpn-tls.nix
    ./vpn-magic-dns.nix
  ];
}
