{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Sunshine pinned to known-good revision
    nixpkgs-sunshine.url = "github:NixOS/nixpkgs/ed142ab1b3a092c4d149245d0c4126a5d7ea00b0";

    # Cloudflare WARP pinned to your known-good revision (from nixos-version: ...cf59864)
    nixpkgs-warp.url = "github:NixOS/nixpkgs/cf59864";

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

  outputs = { self, nixpkgs, nixpkgs-sunshine, nixpkgs-warp, home-manager, solaar, yazi, ... }:
  let
    system = "x86_64-linux";

    overlays = [
      yazi.overlays.default

      # Sunshine stays on the pinned nixpkgs revision
      (final: prev: {
        sunshine = (import nixpkgs-sunshine {
          system = prev.system;
          config.allowUnfree = true;
        }).sunshine;
      })

      # WARP stays on the pinned nixpkgs revision
      (final: prev: {
        cloudflare-warp = (import nixpkgs-warp {
          system = prev.system;
          config.allowUnfree = true;
        }).cloudflare-warp;
      })
    ];
  in
  {
    nixosConfigurations.rt4817 = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        solaar.nixosModules.default

        ({ ... }: { nixpkgs.overlays = overlays; })

        # Force the service to use the pinned package explicitly (extra safety)
        ({ pkgs, ... }: {
          services.cloudflare-warp.package = pkgs.cloudflare-warp;
        })

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
