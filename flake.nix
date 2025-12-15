
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Solaar via FlakeHub (aligned to nixpkgs)
    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Yazi flake (for yazi.packages.${system}.default)
    yazi.url = "github:sxyazi/yazi";
    
    pixy2 = {
      url = "path:/home/joel/pixy2";  # use absolute path; ~ is NOT expanded in Nix
      flake = false;                  # <-- critical: this prevents Nix from expecting flake.nix
    };

  };

  outputs = { self, nixpkgs, home-manager, solaar, yazi, pixy2, ... }: {
    nixosConfigurations.rt4817 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
       ({ config, pkgs, ... }: {
       # Copy Pixy udev rule into /etc/udev/rules.d/
          environment.etc."udev/rules.d/pixy.rules".source = "$(pixy2)/src/host/linux/pixy.rules";  # Adjust path relative to flake.nix
          
            environment.systemPackages = with pkgs; [
              # If your yazi derivation supports `_7zz`, this works.
              # Otherwise switch to overrideAttrs or install _7zz-rar alongside (see notes below).
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
          }
        )
        # Other modules in the list are fine as paths or module values
        solaar.nixosModules.default
        ./configuration.nix

        home-manager.nixosModules.home-manager
        ({ pkgs, ... }:
          {
                       home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.joel = import ./home.nix;
          }
        )
      ];
    };
  };
}
