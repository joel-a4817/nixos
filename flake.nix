
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
      # Alternative pins if needed:
      # url = "https://flakehub.com/f/Svenum/Solaar-Flake/0.1.6.tar.gz";
      # url = "github:Svenum/Solaar-Flake/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Yazi flake (for yazi.packages.${system}.default)
    yazi.url = "github:sxyazi/yazi";
  };

  outputs = { self, nixpkgs, home-manager, solaar, yazi, ... }: {
    nixosConfigurations.rt4817 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({config, pkgs, ...}:
      {
        environment.etc."udev/rules.d/99-pixy.rules".source = ./files/udev/99-pixy.rules;
        environment.systemPackages = with pkgs; [
          (yazi.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
            _7zz = pkgs._7zz-rar;
          })

        # Preview / thumbnails / metadata / search helpers for Yazi
          ueberzugpp        # inline image previews via Kitty graphics (works in Foot)            
          ffmpegthumbnailer # video thumbnails
          poppler           # PDF tools (pdftoppm, pdftotext)
          imagemagick       # image conversions/resizing
          exiftool          # media metadata
          fd                # fast find
          ripgrep           # fast grep inside files
          jq                # JSON parsing for plugins
          chafa             # ANSI image fallback (nice to have)
          bat               # syntax-highlighted previews
          fzf               # fuzzy finder (also handy with Yazi)
        ];
      }
        )
        solaar.nixosModules.default
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.joel = import ./home.nix;
        }
      ];
    };
  };
}
