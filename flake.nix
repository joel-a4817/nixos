
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Yazi flake (for yazi.packages.${system}.default)
    yazi.url = "github:sxyazi/yazi";

    # Your local Pixy2 directory (NOT a flake)
    pixy2 = {
      url = "path:/home/joel/pixy2";
      flake = false;
    };

    solaar = {
      url = "github:Svenum/Solaar-Flake/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, pixy2, solaar, yazi, ... }: {
    nixosConfigurations.rt4817 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { pixy2 = pixy2; };
      modules = [
        # Pixy2 udev rule (guarded)
        ({ pixy2, ... }: {
          services.udev.extraRules =
            let p = pixy2 + "/src/host/linux/pixy.rules";
            in if builtins.pathExists (builtins.toPath p)
               then builtins.readFile (builtins.toPath p)
               else ''
                 # Pixy2 rules not found at ${p}; skipping.
               '';
        })
        
        #yazi
				({ pkgs, ... }: {
					environment.systemPackages = [
	  				(yazi.packages.${pkgs.system}.default.override {
							_7zz = pkgs._7zz-rar;  # Support for RAR extraction
						})
          ];
				})

        # Solaar module
        solaar.nixosModules.default

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


