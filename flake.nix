{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Sunshine pinned to the known-good revision from your flake.lock
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

  outputs = { self, nixpkgs, nixpkgs-sunshine, home-manager, solaar, yazi, ... }: {
    nixosConfigurations.rt4817 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [

        solaar.nixosModules.default

        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            yazi.overlays.default

            # ⭐ Sunshine stays on ed142ab1… (yesterday's working version)
            (final: prev: {
              sunshine = (import nixpkgs-sunshine {
                system = prev.system;
              }).sunshine;
            })
          ];
        })

        ./configuration.nix

        home-manager.nixosModules.home-manager
        ({ ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.joel = { pkgs, ... }: {
            imports = [ ./home.nix ];
          };
        })
      ];
    };
  };
}
