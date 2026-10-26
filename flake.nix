{
  description = "J-hareng custom server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    copyparty.url = "github:9001/copyparty";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    degoog = {
      url = "github:degoog-org/degoog";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      copyparty,
      nixpkgs-unstable,
      degoog,
      ...
    }@inputs:
    let
      mkSystem =
        hostname:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            copyparty.nixosModules.default
            { nixpkgs.overlays = [ copyparty.overlays.default ]; }
            ./hosts/vm4
          ];
        };
    in
    {
      nixosConfigurations = {
        hakira = mkSystem "hakira";
      };
    };
}
