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

  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  boot.kernelModules = [ "binder_linux" "ashmem_linux" ];

  # REQUIRED for networking
  networking.nftables.enable = true;

}
