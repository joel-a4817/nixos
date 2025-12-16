
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
    
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz"; # For latest stable version
      #url = "https://flakehub.com/f/Svenum/Solaar-Flake/0.1.6.tar.gz"; # uncomment line for solaar version 1.1.18
      #url = "github:Svenum/Solaar-Flake/main"; # Uncomment line for latest unstable version
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, yazi, pixy2, solaar, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.rt4817 = nixpkgs.lib.nixosSystem {
      inherit system;

      # Make `pixy2` available to module functions
      specialArgs = { inherit pixy2; };

      modules = [
        # Inline NixOS module function
        ({ config, pkgs, pixy2, ... }: {
          # ✅ Write Pixy udev rule via udev (avoids /etc symlink permission errors)
          services.udev.extraRules =
            builtins.readFile (builtins.toPath (pixy2 + "/src/host/linux/pixy.rules"));

          # Packages (your Yazi override + helpers)
          environment.systemPackages = with pkgs; [
            (yazi.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
              _7zz = _7zz-rar;
            })

            # Preview / thumbnails / metadata / search helpers for Yazi
            ueberzugpp
            ffmpegthumbnailer
            poppler
            imagemagick
            exiftool
            fd
            ripgrep
            jq
            chafa
            bat
            fzf
          ];
        })
        
        solaar.nixosModules.default
        ./configuration.nix

        home-manager.nixosModules.home-manager
        ({ pkgs, ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.joel = import ./home.nix;
        })
      ];
    };
  };
}