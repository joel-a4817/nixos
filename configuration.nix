{ config, lib, pkgs, ... }:

let
  pixy2UdevRules = pkgs.stdenvNoCC.mkDerivation {
    pname = "pixy2-udev-rules";
    version = "1";
    src = ./pixy.rules;
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/lib/udev/rules.d
      # name it with a prefix so ordering is sane
      cp "$src" $out/lib/udev/rules.d/99-pixy.rules
    '';
  };

  # Custom python-adblock (Brave Rust-based + Python wrapper for ABP/EasyList support in qutebrowser)
  pythonAdblock = pkgs.callPackage ./python-adblock.nix { };

  # Python 3 with adblock module added (qutebrowser will use this interpreter)
  pythonWithAdblock = pkgs.python3.override {
    packageOverrides = self: super: {
      adblock = pythonAdblock;
    };
  };

  # qutebrowser using the custom Python + WideVine enabled
  qutebrowser-with-adblock = pkgs.qutebrowser.override {
    python3 = pythonWithAdblock;
    enableWideVine = true;
  };

in
{
  # NixOS will collect rule files from packages under {lib,etc}/udev/rules.d
  services.udev.packages = [ pixy2UdevRules ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  services.udev.extraRules = ''
    SUBSYSTEM=="input", KERNEL=="input2", ATTR{device/power/wakeup}="disabled"
  '';

  # Boot (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "rt4817";

  security.sudo.extraRules = [
    {
      users = [ "joel" ];
      commands = [
        { command = "/run/current-system/sw/bin/timedatectl"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

  # Users
  users.users.joel = {
    isNormalUser = true;
    extraGroups = [ "wheel" "seat" "networkmanager" "audio" "video" ];
    packages = with pkgs; [
      tree
    ];
  };

  # Networking
  networking.networkmanager.enable = true;
  hardware.enableAllFirmware = true;

  # Audio (PipeWire + WirePlumber)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # Seatd for wlroots compositors (sway); polkit for permissions
  security.polkit.enable = true;
  services.dbus.enable = true;
  services.seatd.enable = true;
  programs.xwayland.enable = true;

  # start sway with exec sway!!
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  environment.shellAliases = {
    s = "exec sway";
  };

  # virtualbox
  virtualisation.virtualbox = {
    host.enable = true;
    host.enableExtensionPack = true;
    guest.enable = true;
    guest.dragAndDrop = true;
    guest.clipboard = true;
  };
  users.extraGroups.vboxusers.members = [ "joel" ];

  # solaar
  services.solaar = {
    enable = true;
    package = pkgs.solaar;
    window = "show";
    extraArgs = "--headless";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    qutebrowser-with-adblock
    wget git gh
    wmenu swaybg autotiling
    grim slurp wf-recorder
    pulseaudio brightnessctl
    imv mpv unzip zip
    wl-clipboard
    appimage-run
  ];

  # warp
  services.cloudflare-warp = {
    enable = true;
    openFirewall = true;
  };

  # Printing
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };
  hardware.printers = {
    ensureDefaultPrinter = "BrotherPrinterHome";
    ensurePrinters = [
      {
        deviceUri = "dnssd://Brother%20MFC-L2750DW%20series._ipp._tcp.local/?uuid=e3248000-80ce-11db-8000-3c2af4f6c121";
        location = "home";
        name = "BrotherPrinterHome";
        model = "everywhere";
      }
    ];
  };

  # Fprintd
  services.fprintd.enable = true;
  security.pam.services = {
    system-local-login.fprintAuth = true;
    su.fprintAuth = true;
    system-auth.fprintAuth = true;
    login.fprintAuth = true;
    sudo.fprintAuth = true;
    greetd.fprintAuth = true;
  };
  security.pam.services.swaylock = {
    enable = true;
    fprintAuth = true;
    unixAuth = true;
  };

  # OpenGL - wlroots like sway need
  hardware.graphics.enable = true;

  # xdg portal enabling
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      };
    };
  };

  # Allow unfree (needed for Widevine)
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
}
