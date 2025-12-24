
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    oxwm = {
      url = "github:tonybanters/oxwm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

  outputs = inputs@{ self, nixpkgs, home-manager, yazi, pixy2, solaar, oxwm, ... }: {
    nixosConfigurations.rt4817 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { pixy2 = pixy2; };
      modules = [
        {
          services.xserver = {
            enable = true;
            windowManager.oxwm.enable = true;
          };
        }

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

        # Fonts + packages — wrapped as a proper module
        ({ pkgs, ... }: {
          fonts = {
            enableDefaultFonts = true;
            fontconfig = {
              enable = true;
              defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];
            };
            packages = [ pkgs.nerd-fonts.jetbrains-mono ];
          };

          environment.systemPackages = with pkgs; [
            # Keep Yazi flake package; no override here
            yazi.packages.${pkgs.stdenv.hostPlatform.system}.default

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

        # Solaar module
        solaar.nixosModules.default

        # Your other NixOS config
        ./configuration.nix

        # Home Manager
        home-manager.nixosModules.home-manager
        ({ ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.joel = { pkgs, ... }: {
            imports = [ ./home.nix ];
            home.stateVersion = "25.11";

            programs.foot = {
              enable = true;
              settings = {
                main = {
                  font = "JetBrainsMono Nerd Font:size=16";
                };
                colors = {
                  foreground = "ffffff";
                  background = "101010";
                  alpha = 0.88;
                };
              };
            };
          };
        })
      ];
    };
  };
}


