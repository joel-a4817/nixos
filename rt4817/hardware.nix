{ config, lib, pkgs, ... }:
let
  pixy2UdevRules = pkgs.stdenvNoCC.mkDerivation {
    pname = "pixy2-udev-rules";
    version = "1";
    src = ./../pixy.rules;
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/lib/udev/rules.d
      # name it with a prefix so ordering is sane
      cp "$src" $out/lib/udev/rules.d/99-pixy.rules
    '';
  };
in
{
#Required for moonlight
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver      # iHD (modern Intel, REQUIRED)
      intel-vaapi-driver      # legacy fallback
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
  environment.systemPackages = with pkgs; [
    mesa
    libva
    libva-utils
  ];

  boot.kernelModules = [ "uinput" ];

  # Boot (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.logind.settings.Login = {
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  powerManagement.enable = true;
  services.tlp.enable = true;

  # NixOS will collect rule files from packages under {lib,etc}/udev/rules.d
  services.udev.packages = [ pixy2UdevRules ];

  services.udev.extraRules = ''
  
# Dell/Lenovo with Elan touchpad
SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Elan Touchpad", SYMLINK+="input/touchpad-internal"

# First laptop with Synaptics/UTS (SYNA)
SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="SYNA30BC:00 06CB:CE07 Touchpad", SYMLINK+="input/touchpad-internal"

# Internal mouse (Logitech M720)
SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Logitech M720 Triathlon", SYMLINK+="input/mouse-internal"

# uinput permissions
KERNEL=="uinput", GROUP="input", MODE="0660", TAG+="uaccess"

  '';
}
