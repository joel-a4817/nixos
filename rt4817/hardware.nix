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
  boot.kernelModules = [ "uinput" ];

  # Boot (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.logind.settings.Login = {
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  # NixOS will collect rule files from packages under {lib,etc}/udev/rules.d
  services.udev.packages = [ pixy2UdevRules ];

  services.udev.extraRules = ''
  # Dell/Lenovo with Elan touchpad
  SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Elan Touchpad", SYMLINK+="input/touchpad-internal"
  # first laptop with Synaptics/UTS (SYNA)
  SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="SYNA30BC:00 06CB:CE07 Touchpad", SYMLINK+="input/touchpad-internal"
  # uinput permissions
  KERNEL=="uinput", GROUP="input", MODE="0660", TAG+="uaccess"

    # ACPI: lid switch (PNP0C0D)
    ACTION=="add|change", SUBSYSTEM=="acpi", KERNEL=="PNP0C0D:*", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

    # ACPI: battery/AC device (PNP0C0A)
    ACTION=="add|change", SUBSYSTEM=="acpi", KERNEL=="PNP0C0A:*", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

    # ACPI: sleep button (PNP0C0E)
    ACTION=="add|change", SUBSYSTEM=="acpi", KERNEL=="PNP0C0E:*", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

    # ACPI: power button (LNXPWRBN) — keep enabled
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

    ## lenovo (second machine specifics)

    # ACPI: LID switch (specific instance)
    ACTION=="add|change", SUBSYSTEM=="acpi", KERNEL=="PNP0C0D:00", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

    # ACPI: sleep button (specific instance)
    ACTION=="add|change", SUBSYSTEM=="acpi", KERNEL=="PNP0C0E:00", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

    # Platform: AWAC (timer)
    ACTION=="add|change", SUBSYSTEM=="platform", KERNEL=="ACPI000E:00", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

    # Platform: rtsx_pci_sdmmc (SD reader)
    ACTION=="add|change", SUBSYSTEM=="platform", KERNEL=="rtsx_pci_sdmmc.0", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

    # PCI devices discovered in /proc/acpi/wakeup
    # GLAN
    ACTION=="add|change", SUBSYSTEM=="pci", KERNEL=="0000:00:1f.6", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
    # XHC (USB)
    ACTION=="add|change", SUBSYSTEM=="pci", KERNEL=="0000:00:14.0", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
    # HDAS
    ACTION=="add|change", SUBSYSTEM=="pci", KERNEL=="0000:00:1f.3", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
    # RP09
    ACTION=="add|change", SUBSYSTEM=="pci", KERNEL=="0000:00:1d.0", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
    # PXSX
    ACTION=="add|change", SUBSYSTEM=="pci", KERNEL=="0000:03:00.0", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
    # PXSX
    ACTION=="add|change", SUBSYSTEM=="pci", KERNEL=="0000:05:00.0", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
    # CNVW (WiFi/BT)
    ACTION=="add|change", SUBSYSTEM=="pci", KERNEL=="0000:00:14.3", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
  '';
}
