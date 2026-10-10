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
    artcraft.url = "github:ipeglin/artcraft-nix";
    wordcraft-src = { url = "github:storytold/wordcraft"; flake = false; };
    gridcraft-src = { url = "github:storytold/gridcraft"; flake = false; };
    deckcraft-src = { url = "github:storytold/deckcraft"; flake = false; };
  };
  outputs = { self, nixpkgs, home-manager, yazi, glide, artcraft, wordcraft-src, gridcraft-src, deckcraft-src, ... }:
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
        artcraft.nixosModules.default
        ({ ... }: { programs.artcraft.enable = true; })
        ({ pkgs, lib, ... }:
          let
            mkCraft = pname: desktopName: src:
              pkgs.rustPlatform.buildRustPackage {
                inherit pname src;
                version = "source";
                cargoLock.lockFile = "${src}/Cargo.lock";
                cargoBuildFlags = [ "-p" pname "-p" "${pname}-cli" ];
                nativeBuildInputs = [ pkgs.pkg-config pkgs.makeWrapper ];
                buildInputs = [ pkgs.alsa-lib pkgs.openssl ];
                doCheck = false;
                postInstall = ''
                  wrapProgram "$out/bin/${pname}" \
                    --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
                      pkgs.libGL pkgs.vulkan-loader pkgs.wayland
                      pkgs.libxkbcommon pkgs.libx11 pkgs.libxcb
                      pkgs.libxcursor pkgs.libxi pkgs.libxrandr
                      pkgs.dbus pkgs.alsa-lib
                    ]}"
                  mkdir -p "$out/share/applications"
                  cp ${pkgs.makeDesktopItem {
                    name = pname;
                    inherit desktopName;
                    exec = "${pname} %F";
                    terminal = false;
                    categories = [ "Office" ];
                  }}/share/applications/* "$out/share/applications/"
                '';
                meta.mainProgram = pname;
              };
          in {
            environment.systemPackages = [
              (mkCraft "wordcraft" "WordCraft" wordcraft-src)
              (mkCraft "gridcraft" "GridCraft" gridcraft-src)
              (mkCraft "deckcraft" "DeckCraft" deckcraft-src)
            ];
          })
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
