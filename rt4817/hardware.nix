{ config, lib, pkgs, ... }:

{
  # Boot (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Boot (BIOS)
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda";

  # camilladsp alsa
  boot.kernelModules = [
    "snd-aloop"
  ];

  services.logind.settings.Login = {
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  hardware.graphics.enable = true; #opengl
  hardware.enableAllFirmware = true;

  powerManagement.enable = true;
  services.tlp.enable = true;

  # NixOS will collect rule files from packages under {lib,etc}/udev/rules.d

  services.udev.extraRules = ''
  
# Dell/Lenovo with Elan touchpad
SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Elan Touchpad", SYMLINK+="input/touchpad-internal"

# First laptop with Synaptics/UTS (SYNA)
SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="SYNA30BC:00 06CB:CE07 Touchpad", SYMLINK+="input/touchpad-internal"

# Internal mouse (Logitech M720)
SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Logitech M720 Triathlon", SYMLINK+="input/mouse-internal"

# uinput permissions
KERNEL=="uinput", GROUP="input", MODE="0660", TAG+="uaccess"

# Optical Drive access for K3b
KERNEL=="sr[0-9]*", GROUP="cdrom", MODE="0660"

# mouse can wake up device
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c52b", ATTR{power/wakeup}="enabled"
  '';

  services.udisks2.enable = true;
}
