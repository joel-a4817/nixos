{ config, pkgs, lib, glideWithCodecs, ... }:

{
  home.packages = with pkgs; [
    clipse
    glideWithCodecs
    anki
    kdePackages.kamoso
    collabora-desktop
    discord signal-desktop karere
    prismlauncher kicad bambu-studio
    socat #play/pause mpv from anywhere
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
