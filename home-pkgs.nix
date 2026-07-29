{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    localsend 
    ungoogled-chromium poppler-utils #svg -> pdf 
    anki
    kdePackages.kamoso
    clipse calcurse
    collabora-desktop
    discord signal-desktop karere
    prismlauncher kicad bambu-studio opencv
    trash-cli lazygit fd ripgrep nushell #required by yazi plugins
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
}
