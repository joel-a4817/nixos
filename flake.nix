{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-22.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yazi.url = "github:sxyazi/yazi";

    solaar = {
      url = "github:Svenum/Solaar-Flake/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-old, home-manager, solaar, yazi, ... }:
  let
    system = "x86_64-linux";

    pkgsOld = import nixpkgs-old {
      inherit system;
    };

    overlays = [
      yazi.overlays.default
    ];
  in
  {
    nixosConfigurations.rt4817 = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit pkgsOld;
      };

      modules = [
        solaar.nixosModules.default

        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            (final: prev: {
              wvkbd-deskintl = prev.wvkbd.overrideAttrs (old: {
                buildPhase = ''
                  make LAYOUT=deskintl
                '';
                installPhase = ''
                  runHook preInstall
                  mkdir -p $out/bin
                  install -Dm755 wvkbd-deskintl $out/bin/wvkbd-deskintl
                  runHook postInstall
                '';
              });
            })
          ];
          environment.systemPackages = [
            pkgs.wvkbd-deskintl
          ];
        })

        ({ ... }: { nixpkgs.overlays = overlays; })

        ./configuration.nix

        home-manager.nixosModules.home-manager

        ({ ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.joel = import ./home.nix;
        })
      ];
    };
  };
}
