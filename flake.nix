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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      copyparty,
      nixpkgs-unstable,
      degoog,
      sops-nix,
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
            sops-nix.nixosModules.sops
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
