{ config, pkgs, lib, ... }:
{
  home.username = "joel";
  home.homeDirectory = "/home/joel";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  # Cursor settings (configure in sway)
  home.pointerCursor = {
    name = "Bibata-Modern-Amber";
    package = pkgs.bibata-cursors;
    gtk.enable = true;
    x11.enable = true;
  };

programs.git = {
  enable = true;
  settings = {
    user = {
      user.name = "rt4817";
      user.email = "joel.ag789@gmail.com";
    };
    init.defaultBranch = "main";
  };
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
    ffmpeg p7zip jq poppler fzf zoxide resvg imagemagick
    trash-cli lazygit fd ripgrep nushell #required by yazi plugins
  ];

programs.foot = {
  enable = true;
  settings = {
    main = {
      font = "JetBrainsMono Nerd Font:size=16";
    };
    colors = {
      alpha = 0.90;
      background = "1d1c22";
      foreground = "ffffff";
    };
  };
};

  programs.yazi = {
    enable = true;
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
