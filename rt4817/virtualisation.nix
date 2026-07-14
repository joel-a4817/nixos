{ config, lib, pkgs, ... }:

{
  # virtualbox
  virtualisation.virtualbox = {
    host.enable = true;
    host.enableExtensionPack = true;
    guest.enable = true;
    guest.dragAndDrop = true;
    guest.clipboard = true;
  };
}
