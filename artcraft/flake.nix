{
  description = "Verified upstream StoryTold ArtCraft release packages for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = lib.genAttrs supportedSystems;
      manifest = builtins.fromJSON (builtins.readFile ./releases.json);

      mkPackages = system:
        let
          pkgs = import nixpkgs { inherit system; };

          # Upstream GUI binaries load several window-system and graphics
          # libraries at runtime with dlopen(), so they do not all appear in
          # ELF DT_NEEDED and cannot be handled by autoPatchelfHook alone.
          runtimeLibraries = with pkgs; [
            stdenv.cc.cc.lib
            glibc
            zlib
            bzip2
            xz
            openssl
            alsa-lib
            pulseaudio
            dbus
            glib
            fontconfig
            freetype
            expat
            libGL
            libglvnd
            vulkan-loader
            wayland
            libxkbcommon
            libX11
            libxcb
            libXcursor
            libXi
            libXrandr
            libXrender
            libXext
            libXfixes
            libXinerama
            libXdamage
            libXcomposite
            libXtst
          ];

          runtimeLibraryPath = lib.makeLibraryPath runtimeLibraries;

          mkApp = name: spec:
            pkgs.stdenvNoCC.mkDerivation {
              pname = name;
              version = lib.removePrefix "v" spec.version;
              src = pkgs.fetchurl {
                inherit (spec) url hash;
              };

              nativeBuildInputs = with pkgs; [
                autoPatchelfHook
                makeWrapper
              ];
              buildInputs = runtimeLibraries;

              strictDeps = true;
              dontConfigure = true;
              dontBuild = true;

              unpackPhase = ''
                runHook preUnpack
                mkdir source
                tar -xzf "$src" -C source
                runHook postUnpack
              '';

              installPhase = ''
                runHook preInstall
                mkdir -p "$out"
                cp -a source/. "$out/"

                gui=$(find "$out" -type f -perm -0100 -name '${name}' -print -quit)
                if [ -z "$gui" ]; then
                  echo "Official archive does not contain executable ${name}" >&2
                  exit 1
                fi

                guiRelative="''${gui#"$out"/}"
                mkdir -p "$out/libexec/${name}" "$out/bin"
                mv "$gui" "$out/libexec/${name}/${name}"
                gui="$out/libexec/${name}/${name}"

                makeWrapper "$gui" "$out/bin/${name}" \
                  --prefix LD_LIBRARY_PATH : '${runtimeLibraryPath}'

                cli=$(find "$out" -type f -perm -0100 -name '${name}-cli' -print -quit)
                if [ -n "$cli" ]; then
                  cliRelative="''${cli#"$out"/}"
                  mv "$cli" "$out/libexec/${name}/${name}-cli"
                  makeWrapper "$out/libexec/${name}/${name}-cli" "$out/bin/${name}-cli" \
                    --prefix LD_LIBRARY_PATH : '${runtimeLibraryPath}'
                fi

                # Preserve all upstream desktop, MIME, icon and AppStream files.
                # Only repair Exec/TryExec when they point at an archive-internal
                # absolute path or command that is not the installed wrapper.
                if [ -d "$out/share/applications" ]; then
                  while IFS= read -r desktop; do
                    substituteInPlace "$desktop" \
                      --replace-regexp '^Exec=[^ ]*' 'Exec=${name}' \
                      --replace-regexp '^TryExec=.*$' 'TryExec=${name}' || true
                  done < <(find "$out/share/applications" -type f -name '*.desktop' -print)
                fi

                runHook postInstall
              '';

              postFixup = ''
                test -x "$out/bin/${name}"
                "$out/bin/${name}" --version >/dev/null 2>&1 || true
              '';

              passthru = {
                upstream = {
                  owner = "storytold";
                  repository = name;
                  inherit (spec) url;
                };
              };

              meta = {
                description = "Official upstream ${name} Linux release, packaged for NixOS";
                homepage = "https://github.com/storytold/${name}";
                license = with lib.licenses; [ mit asl20 ];
                sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
                mainProgram = name;
                platforms = [ system ];
              };
            };

          apps = lib.mapAttrs mkApp manifest;
        in
        apps // {
          default = pkgs.symlinkJoin {
            name = "artcraft-complete-suite";
            paths = builtins.attrValues apps;
          };
        };
    in {
      packages = forAllSystems mkPackages;

      apps = forAllSystems (system:
        lib.mapAttrs
          (name: _: {
            type = "app";
            program = "${self.packages.${system}.${name}}/bin/${name}";
          })
          manifest);

      nixosModules.default = { config, pkgs, lib, ... }:
        let
          cfg = config.programs.localArtcraftSuite;
          availableApps = builtins.attrNames manifest;
        in {
          options.programs.localArtcraftSuite = {
            enable = lib.mkEnableOption "the locally pinned upstream ArtCraft suite";
            apps = lib.mkOption {
              type = lib.types.listOf (lib.types.enum availableApps);
              default = availableApps;
              description = "ArtCraft applications to install.";
            };
          };

          config = lib.mkIf cfg.enable {
            assertions = [{
              assertion = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
              message = "localArtcraftSuite currently pins x86_64 Linux releases.";
            }];
            environment.systemPackages = map
              (name: self.packages.${pkgs.stdenv.hostPlatform.system}.${name})
              cfg.apps;
          };
        };
    };
}
