
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
      #url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz"; # latest stable
      #url = "https://flakehub.com/f/Svenum/Solaar-Flake/0.1.6.tar.gz"; # pin solaar 1.1.18
      url = "github:Svenum/Solaar-Flake/main"; # latest unstable
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, yazi, pixy2, solaar, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    nixosConfigurations.rt4817 = nixpkgs.lib.nixosSystem {
      inherit system;

      # Make `pixy2` available to module functions
      specialArgs = { inherit pixy2; };

      modules = [
        # Inline NixOS module function
        ({ config, pkgs, pixy2, ... }: {
          # Write Pixy udev rule via udev (avoids /etc symlink permission errors)
          services.udev.extraRules =
            builtins.readFile (builtins.toPath (pixy2 + "/src/host/linux/pixy.rules"));

          fonts = {
            enableDefaultFonts = true;
            fonts = with pkgs; [ nerd-fonts.jetbrains-mono ];
            fontconfig.enable = true;
            fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];
          };

          # Packages (your Yazi override + helpers)
          environment.systemPackages = with pkgs; [
            (yazi.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
              _7zz = _7zz-rar;
            })

            # Preview / thumbnails / metadata / search helpers for Yazi
            ffmpeg
            p7zip
            jq
            poppler
            fd
            ripgrep
            fzf
            zoxide
            resvg
            imagemagick
          ];
        })

        solaar.nixosModules.default
        ./configuration.nix

        # Home Manager as a NixOS module
        home-manager.nixosModules.home-manager

        # Home Manager user config: import `home.nix` and overlay foot settings
        ({ ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.joel = { pkgs, ... }: {
            # Keep your existing Home Manager setup
            imports = [ ./home.nix ];

            # State version (keep or set if not already in home.nix)
            # If home.nix already sets home.stateVersion, you can remove this line.
            home.stateVersion = "25.11";

            # Overlay foot settings (these will merge with whatever `home.nix` defines)
            programs.foot = {
              enable = true;  # safe if already enabled in home.nix
              settings = {
                main = {
                  font = "JetBrainsMono Nerd Font:size=16";
                };
                colors = {
                  foreground = "ffffff";
                  background = "101010";
                  alpha = 0.88;  # transparency
                };
              };
            };
          };
        })
      ];
    };
  };
}
