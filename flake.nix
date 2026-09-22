{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    glide.url = "github:Matthew-K310/glide-flake"; 
    glide.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yazi.url = "github:sxyazi/yazi";
  };

  outputs = { self, nixpkgs, home-manager, yazi, glide, ... }:
  let
    system = "x86_64-linux";

    overlays = [
      yazi.overlays.default
    ];
  in
  {
    nixosConfigurations.rt4817 = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [

        ({ ... }: { nixpkgs.overlays = overlays; })

        ./configuration.nix

        home-manager.nixosModules.home-manager

        ({ pkgs, lib, ... }:

        let
          baseGlide =
            glide.packages.${system}.default;

          compatibleFfmpeg =
            if pkgs ? ffmpeg_8 then
              pkgs.ffmpeg_8
            else
              pkgs.ffmpeg_7;

          glideWithCodecs = pkgs.symlinkJoin {
            name = "glide-with-compatible-ffmpeg";

            paths = [
              baseGlide
            ];

            nativeBuildInputs = [
              pkgs.makeWrapper
            ];

            postBuild = ''
              rm -f "$out/bin/.glide-wrapped"

              wrapProgram "$out/bin/glide" \
                --prefix LD_LIBRARY_PATH : "${
                  lib.makeLibraryPath [
                    compatibleFfmpeg
                  ]
                }"
            '';
          };
        in
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = {
            inherit glideWithCodecs;
          };

          home-manager.users.joel = import ./home.nix;
        })

      ];
    };
  };
}

