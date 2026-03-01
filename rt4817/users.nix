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
        { command = "${pkgs.procps}/bin/pkill"; options = [ "NOPASSWD" ]; }
        { command = "${pkgs.util-linux}/bin/setsid"; options = [ "NOPASSWD" ]; }
        { command = "/home/joel/.config/sway/scripts/rotate-touchpad.py"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

  users.extraGroups.vboxusers.members = [ "joel" ];
}
