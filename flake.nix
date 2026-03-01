{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Sunshine pinned to known-good revision
    nixpkgs-sunshine.url = "github:NixOS/nixpkgs/ed142ab1b3a092c4d149245d0c4126a5d7ea00b0";

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

  outputs = { self, nixpkgs, nixpkgs-sunshine, home-manager, solaar, yazi, ... }:
  let
    system = "x86_64-linux";

    overlays = [
      yazi.overlays.default

      # Sunshine stays on the pinned nixpkgs revision
      (final: prev: {
        sunshine = (import nixpkgs-sunshine { system = prev.system; }).sunshine;
      })
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
