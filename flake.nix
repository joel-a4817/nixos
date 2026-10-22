{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    glide.url = "github:glide-browser/glide";
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

  outputs = { self, nixpkgs, home-manager, yazi, glide, artcraft, ... }:
  let
    system = "x86_64-linux";
    overlays = [
      yazi.overlays.default
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

        home-manager.nixosModules.home-manager

        ({ ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = {
            inherit glide artcraft system;
          };

          home-manager.users.joel = import ./home.nix;
        })
      ];
    };
  };
}
