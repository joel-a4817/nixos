{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Official Glide Browser upstream. No third-party packaging or codec wrapper.
    glide.url = "github:glide-browser/glide";
    glide.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yazi.url = "github:sxyazi/yazi";

    # Your separate local ArtCraft packaging flake.
    artcraft = {
      url = "path:/home/joel/nixos/artcraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, yazi, glide, artcraft, ... }:
  let
    system = "x86_64-linux";
    overlays = [ yazi.overlays.default ];
  in {
    nixosConfigurations.rt4817 = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ({ ... }: {
          nixpkgs.overlays = overlays;
        })

        ./configuration.nix

        home-manager.nixosModules.home-manager

        ({ ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = {
            inherit glide artcraft system;
          };

          home-manager.users.joel = import ./home.nix;
        })
      ];
    };
  };
}
