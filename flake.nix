
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

  outputs = { self, nixpkgs, home-manager, yazi, pixy2, solaar, ... }: {
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

          environment.systemPackages = with pkgs; 
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
            #below are yazi plugins:
            #currently don't need chmod or sudo.
            #yaziPlugins.chmod #https://github.com/yazi-rs/plugins/tree/main/chmod.yazi
            #yaziPlugins.sudo #https://github.com/TD-Sky/sudo.yazi
            yaziPlugins.dupes #https://github.com/Mshnwq/dupes.yazi
            yaziPlugins.git #https://github.com/yazi-rs/plugins/tree/main/git.yazi
            yaziPlugins.lazygit #https://github.com/Lil-Dank/lazygit.yazi
            yaziPlugins.recycle-bin #https://github.com/uhs-robert/recycle-bin.yazi             
            yaziPlugins.toggle-pane #https://github.com/yazi-rs/plugins/tree/main/toggle-pane.yazi
            yaziPlugins.restore #https://github.com/boydaihungst/restore.yazi
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


