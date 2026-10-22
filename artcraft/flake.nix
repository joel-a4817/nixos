{
  description = "Self-maintained ArtCraft suite packages from verified upstream Linux releases";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs { inherit system; };
      manifest = builtins.fromJSON (builtins.readFile ./releases.json);
      mkApp = name: spec:
        pkgs.stdenvNoCC.mkDerivation {
          pname = name;
          version = spec.version;
          src = pkgs.fetchurl { inherit (spec) url hash; };
          nativeBuildInputs = [ pkgs.autoPatchelfHook ];
          buildInputs = with pkgs; [
            stdenv.cc.cc.lib alsa-lib openssl zlib libGL vulkan-loader
            wayland libxkbcommon libX11 libxcb libXcursor libXi libXrandr
            dbus fontconfig freetype glib glibc
          ];
          dontConfigure = true;
          dontBuild = true;
          unpackPhase = ''
            runHook preUnpack
            mkdir -p unpacked
            tar -xzf "$src" -C unpacked
            runHook postUnpack
          '';
          installPhase = ''
            runHook preInstall
            mkdir -p "$out/bin" "$out/share"
            # Flatten one upstream release directory when necessary.
            candidate=$(find unpacked -type f -name '${name}' -print -quit)
            if [ -z "$candidate" ]; then
              echo "Missing executable ${name} in release archive" >&2
              exit 1
            fi
            cp -r unpacked/. "$out/"
            if [ ! -e "$out/bin/${name}" ]; then
              relative="''${candidate#unpacked/}"
              ln -s "../$relative" "$out/bin/${name}"
            fi
            chmod +x "$out/bin/${name}" || true
            runHook postInstall
          '';
          meta = { mainProgram = name; platforms = [ system ]; };
        };
      apps = if manifest == {} then
        throw "ArtCraft releases.json is empty: run python3 artcraft/update-releases.py before building"
        else lib.mapAttrs mkApp manifest;
    in {
      packages.${system} = apps // {
        default = pkgs.symlinkJoin {
          name = "artcraft-complete-suite";
          paths = builtins.attrValues apps;
        };
      };
      nixosModules.default = { config, pkgs, lib, ... }: {
        options.programs.localArtcraftSuite.enable = lib.mkEnableOption "all locally pinned ArtCraft apps";
        config = lib.mkIf config.programs.localArtcraftSuite.enable {
          environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.default ];
        };
      };
    };
}
