{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Yazi flake (for yazi.packages.${system}.default)
    yazi.url = "github:sxyazi/yazi";

    solaar = {
      url = "github:Svenum/Solaar-Flake/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, solaar, yazi, ... }: {
    nixosConfigurations.rt4817 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [

        # Solaar module
        solaar.nixosModules.default

        ({ pkgs, ... }: {
          nixpkgs.overlays = [ yazi.overlays.default ];
        })

        ./configuration.nix

        # Home Manager
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
