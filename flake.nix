{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yazi.url = "github:sxyazi/yazi";

    solaar = {
      url = "github:Svenum/Solaar-Flake/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, solaar, yazi, ... }:
  let
    system = "x86_64-linux";

    overlays = [
      yazi.overlays.default
    ];
  in
  {
    nixosConfigurations.rt4817 = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        solaar.nixosModules.default

        ({ ... }: { nixpkgs.overlays = overlays; })

        ./configuration.nix

        home-manager.nixosModules.home-manager
        ({ ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.joel = import ./home.nix;
        })
      ];
    };
  };
}
