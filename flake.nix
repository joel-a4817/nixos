{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    glide.url = "github:Matthew-K310/glide-flake"; 
    glide.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yazi.url = "github:sxyazi/yazi";

  };

  outputs = { self, nixpkgs, home-manager, yazi, glide, ... }:
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
        ({ ... }: { nixpkgs.overlays = overlays; })

        ./configuration.nix

        home-manager.nixosModules.home-manager

        ({ ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit glide;
          };
          home-manager.users.joel = import ./home.nix;
        })
      ];
    };
  };
}

