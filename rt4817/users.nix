{ config, lib, pkgs, ... }:

{ 
  environment.shellAliases = {
    s = "exec sway";
  };

  # Users
  users.users.joel = {
    home = lib.mkForce "/home/joel";
    isNormalUser = true;
    isSystemUser = lib.mkForce false;
    extraGroups = [ "wheel" "seat" "networkmanager" "audio" "video" "input" "cdrom" "libvirtd" "kvm" ];
  };

security.sudo.extraRules = [
  {
    users = [ "joel" ];
    commands = [
      { command = "/run/current-system/sw/bin/timedatectl"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/pkill"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/setsid"; options = [ "NOPASSWD" ]; }
      { command = "/home/joel/.config/sway/scripts/rotate-touchpad.py"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/systemctl restart nqptp.service"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/systemctl restart shairport-sync.service"; options = [ "NOPASSWD" ]; }
    ];
  }
];
}
