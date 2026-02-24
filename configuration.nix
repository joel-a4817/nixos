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
      /etc/nixos/hardware-configuration.nix
    ];

services.udev.extraRules = ''
  # ACPI: lid switch (PNP0C0D)
  ACTION=="add|change", SUBSYSTEM=="acpi", KERNEL=="PNP0C0D:*", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

  # ACPI: battery/AC device (PNP0C0A)
  ACTION=="add|change", SUBSYSTEM=="acpi", KERNEL=="PNP0C0A:*", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

  # ACPI: sleep button (PNP0C0E)
  ACTION=="add|change", SUBSYSTEM=="acpi", KERNEL=="PNP0C0E:*", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

  # ACPI: power button (LNXPWRBN) — keep enabled (flip to disabled if you want keyboard-only)
  ACTION=="add|change", SUBSYSTEM=="acpi", KERNEL=="LNXPWRBN:*", TEST=="power/wakeup", ATTR{power/wakeup}="enabled"

  # I2C: Synaptics touchpad/touchscreen (SYNA30BC)
  ACTION=="add|change", SUBSYSTEM=="i2c", KERNEL=="i2c-SYNA30BC:00", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
  ACTION=="add|change", SUBSYSTEM=="i2c", KERNEL=="i2c-SYNA30BC:00", TEST=="device/power/wakeup", ATTR{device/power/wakeup}="disabled"

  # Platform: INTC1051:00
  ACTION=="add|change", SUBSYSTEM=="platform", KERNEL=="INTC1051:00", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

  # Platform: alarmtimer.0.auto
  ACTION=="add|change", SUBSYSTEM=="platform", KERNEL=="alarmtimer.0.auto", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

  # PNP: 00:01
  ACTION=="add|change", SUBSYSTEM=="pnp", KERNEL=="00:01", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

  # Thunderbolt: both nodes you reported
  ACTION=="add|change", SUBSYSTEM=="thunderbolt", KERNEL=="domain0", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
  ACTION=="add|change", SUBSYSTEM=="thunderbolt", KERNEL=="0-0", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

  # USB: keep wake disabled for any usb device exposing it
  ACTION=="add|change", SUBSYSTEM=="usb", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

  # PCI: keep wake disabled for any pci device exposing it
  ACTION=="add|change", SUBSYSTEM=="pci", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

  # Re-enable only the PS/2 keyboard (serio0 atkbd)
  ACTION=="add|change", SUBSYSTEM=="serio", KERNEL=="serio0", ATTR{description}=="i8042 KBD port", TEST=="power/wakeup", ATTR{power/wakeup}="enabled"
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
    grim slurp wf-recorder wl-clipboard
    xwallpaper dmenu xclip maim ffmpeg
    pulseaudio brightnessctl
    imv mpv unzip zip
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

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
  };
  networking.firewall.allowedTCPPorts = [ 8384 47984 47989 47990 48010 ];
  networking.firewall.allowedUDPPortRanges = [{ from = 47998; to = 48000;}];
  services.sunshine.enable = true;

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

nix.settings = {
  max-jobs = 1;
  cores = 1;
};

  # Allow unfree (needed for Widevine)
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
}
