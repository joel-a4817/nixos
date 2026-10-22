{ config, pkgs, lib, glideWithCodecs, ... }:

{
  home.packages = with pkgs; [
    clipse
    glideWithCodecs
    kdePackages.kamoso
    discord signal-desktop karere
    prismlauncher
    socat #play/pause mpv from anywhere
    blender
  ];

  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
    package = pkgs.yazi.override { _7zz = pkgs._7zz-rar; }; # Support for RAR extraction
    plugins = {
      sudo = pkgs.yaziPlugins.sudo; #https://github.com/TD-Sky/sudo.yazi
      lazygit = pkgs.yaziPlugins.lazygit; #https://github.com/Lil-Dank/lazygit.yazi
      recycle-bin = pkgs.yaziPlugins.recycle-bin; #https://github.com/uhs-robert/recycle-bin.yazi
      restore = pkgs.yaziPlugins.restore; #https://github.com/boydaihungst/restore.yazi
    };
  };

  programs.fastfetch.enable = true;
}
