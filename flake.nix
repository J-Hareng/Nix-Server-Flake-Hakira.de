{
  description = "J-hareng custom server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

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
    {
      nixosConfigurations.hakira = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          inherit inputs;
          TailnetName = "pufferfish-terrapin.ts.net";
          Domain = "hakira.de";
        };

        modules = [

          copyparty.nixosModules.default
          { nixpkgs.overlays = [ copyparty.overlays.default ]; }

          sops-nix.nixosModules.sops

          ./hosts/vm4
        ];
      };
    };
}
