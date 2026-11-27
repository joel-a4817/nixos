{ config, lib, pkgs, ... }:

let
  # Temporary narrow fix for json-c 0.19: json_object_put() placed the free
  # operation inside assert(), so -DNDEBUG builds leaked non-empty JSON trees.
  # This derivation patches only the json-c copy loaded by Sway.
  swayJsonC = pkgs.json_c.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      target=json_object.c
      broken='assert(_json_object_put_maybe_free(jso, 1) == 0);'

      if ! grep -Fq "$broken" "$target"; then
        echo "json-c workaround expected the vulnerable 0.19 source line, but it was not found" >&2
        exit 1
      fi

      substituteInPlace "$target" \
        --replace-fail "$broken" \
        'int json_c_put_result_f291fa81c = _json_object_put_maybe_free(jso, 1); assert(json_c_put_result_f291fa81c == 0);'
    '';
  });

  # Sway's package function does not accept a json_c argument. Copy the existing
  # Sway output and modify only ELF files that directly need libjson-c.so.5,
  # placing the patched library first in their runtime search path.
  swayWithJsonCFix = pkgs.runCommand "${pkgs.sway.name}-json-c-f291fa81c" {
    nativeBuildInputs = [ pkgs.patchelf pkgs.findutils pkgs.coreutils ];
  } ''
    cp -a ${pkgs.sway} "$out"
    chmod -R u+w "$out"

    patched=0
    while IFS= read -r -d '' file; do
      if patchelf --print-needed "$file" 2>/dev/null | grep -Fxq 'libjson-c.so.5'; then
        old_rpath="$(patchelf --print-rpath "$file")"
        patchelf --set-rpath "${swayJsonC}/lib''${old_rpath:+:$old_rpath}" "$file"
        patched=$((patched + 1))
      fi
    done < <(find "$out" -type f -print0)

    if [ "$patched" -eq 0 ]; then
      echo "No Sway ELF file linked to libjson-c.so.5 was found" >&2
      exit 1
    fi
  '';
in
{
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: [
        pkgs.webkitgtk_4_1
        pkgs.libsoup_3
        pkgs.mpv
        pkgs.libepoxy
        pkgs.gtk3
        pkgs.glib
        pkgs.pango
        pkgs.harfbuzz
        pkgs.cairo
        pkgs.gdk-pixbuf
        pkgs.atk
        pkgs.fontconfig
        pkgs.zlib
        pkgs.stdenv.cc.cc
      ];
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.xwayland.enable = true;

  programs.sway = {
    enable = true;
    package = swayWithJsonCFix;
    wrapperFeatures.gtk = true;
    xwayland.enable = true;
  };

  programs.nix-ld = {
    enable = true;

    libraries = with pkgs; [
      stdenv.cc.cc
      glibc
      libedit
      ncurses
      zlib
      z3
      libxml2
      util-linux
    ];
  };

  # System-wide Theos location.
  environment.sessionVariables = {
    THEOS = "/opt/theos";
  };

  environment.systemPackages = with pkgs; [
    (python3.withPackages (python-pkgs: with python-pkgs; [
      evdev pip numpy soundfile scipy h5py psutil matplotlib pandas pyyaml netcdf4 requests platformdirs
  ])) #bunch of the audio pkgs
    web-ext
    glib

    (bleachbit.overridePythonAttrs (old: {
      propagatedBuildInputs =
        (old.propagatedBuildInputs or [])
        ++ [ python3Packages.psutil ];
    }))
    xhost procps 
    util-linux exfatprogs dosfstools ntfs3g e2fsprogs parted

    # Graphics
    mesa libva libva-utils

    # Java
    temurin-jre-bin

    # Development and Git
    wget git gh

    # Sway
    wmenu swaybg autotiling grim slurp wf-recorder wl-clipboard

    # Audio and hardware
    pulseaudio brightnessctl alsa-utils camilladsp nqptp usbutils libimobiledevice psmisc # for web script
    sonobus
    libplist frida-tools #ipad website stuff
    socat wayvnc playerctl

    # Media and applications
    imv mpv ffmpeg

    # Archives and optical media
    unzip zip p7zip cdrkit dvdplusrwtools

    # Qt applications from Home Manager
    qt6.qtwayland

    mcrcon

    # Compatibility
    steam-run

    # Yazi and scripts
    fzf zoxide resvg imagemagick jq trash-cli lazygit fd ripgrep nushell
    ripdrag

    gnome-themes-extra #dark theme

    # Theos build dependencies
    bash coreutils curl gnumake gnused gnugrep gawk findutils which file rsync perl dpkg fakeroot libxml2 ncurses zlib z3 libedit clang lld llvm xz gzip bzip2 gnutar ldid

    kbd #sway shell

    android-tools
  ];
}
