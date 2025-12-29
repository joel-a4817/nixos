{ config, pkgs, lib, ... }:
{
  home.username = "joel";
  home.homeDirectory = "/home/joel";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  # Cursor settings
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    gtk.enable = true;
    x11.enable = true;
  };

  # User packages
  home.packages = with pkgs; [
    prismlauncher
    signal-desktop
    kicad
    prusa-slicer
    bambu-studio
    opencv
    qt5.qtwayland #Required for Qt apps like those above.
    #yazi pkgs:
    ffmpeg p7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick
    trash-cli jdupes lazygit #required by yazi plugins
  ];

  programs.yazi = {
    enable = true;
    package = pkgs.yazi.override { _7zz = pkgs._7zz-rar; }; # Support for RAR extraction
    plugins = { #don't need chmod or sudo for now.
      #yaziPlugins.chmod #https://github.com/yazi-rs/plugins/tree/main/chmod.yazi
      #yaziPlugins.sudo #https://github.com/TD-Sky/sudo.yazi
      
      dupes       = pkgs.yaziPlugins.dupes; #https://github.com/Mshnwq/dupes.yazi
      git         = pkgs.yaziPlugins.git; #https://github.com/yazi-rs/plugins/tree/main/git.yazi
      lazygit     = pkgs.yaziPlugins.lazygit; #https://github.com/Lil-Dank/lazygit.yazi
      recycle-bin = pkgs.yaziPlugins.recycle-bin; #https://github.com/uhs-robert/recycle-bin.yazi
      restore     = pkgs.yaziPlugins.restore; #https://github.com/boydaihungst/restore.yazi
    };
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=16";
      };
      colors = {
        foreground = "ffffff";
        background = "101010";
        alpha = 0.88;
      };
    };
  };

programs.fastfetch.enable = true;

}


