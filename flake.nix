{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    glide.url = "github:glide-browser/glide.nix";
    glide.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yazi.url = "github:sxyazi/yazi";

    artcraft = {
      url = "path:/home/joel/nixos/artcraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-minecraft, home-manager, yazi, glide, artcraft, ... }:
  let
    system = "x86_64-linux";
    overlays = [
      yazi.overlays.default
      nix-minecraft.overlay
      (final: prev: {
        sonobus = prev.sonobus.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            substituteInPlace Source/VersionInfo.h \
              --replace-fail 'VersionInfo() = default;' \
              'VersionInfo (String version, String notes, std::vector<Asset> parsedAssets) : versionString (std::move (version)), releaseNotes (std::move (notes)), assets (std::move (parsedAssets)) {}'
            substituteInPlace Source/VersionInfo.cpp \
              --replace-fail 'new VersionInfo ({ versionString, releaseNotes, std::move (parsedAssets) })' \
              'new VersionInfo (versionString, releaseNotes, std::move (parsedAssets))'
          '';
        });
      })
    ];
  in {
    nixosConfigurations.rt4817 = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ({ ... }: {
          nixpkgs.overlays = overlays;
        })

        ./configuration.nix
        nix-minecraft.nixosModules.minecraft-servers

        home-manager.nixosModules.home-manager

        ({ ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = {
            inherit glide artcraft system;
          };

          home-manager.users.joel = {
            imports = [
              ./home.nix
            ];

            home.packages = [
              glide.packages.${system}.default
              artcraft.packages.${system}.default
            ];
          };
        })
      ];
    };
  };
}
