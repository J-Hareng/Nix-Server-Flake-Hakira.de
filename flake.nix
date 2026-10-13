{
  description = "J-hareng custom server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };
  # Push Test 2
  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      mkSystem =
        hostname:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/vm4
          ];
        };
    in
    {
      nixosConfigurations = {
        server = mkSystem "server";
      };
    };
}
