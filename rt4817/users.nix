{ config, lib, pkgs, ... }:

{  
  # Users
  users.users.joel = {
    isNormalUser = true;
    extraGroups = [ "wheel" "seat" "networkmanager" "audio" "video" "input" ];
  };

security.sudo.extraRules = [
  {
    users = [ "joel" ];
    commands = [
      { command = "/run/current-system/sw/bin/timedatectl"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/pkill"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/setsid"; options = [ "NOPASSWD" ]; }
      { command = "/home/joel/.config/sway/scripts/rotate-touchpad.py"; options = [ "NOPASSWD" ]; }
    ];
  }
];

  users.extraGroups.vboxusers.members = [ "joel" ];
}
