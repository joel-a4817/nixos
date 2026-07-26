{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    localsend yt-dlp
    ungoogled-chromium poppler-utils #svg -> pdf 
    anki
    heimdall-gui android-tools
    libimobiledevice ifuse usbmuxd usbutils
    kdePackages.kamoso
    clipse calcurse
    collabora-desktop
    discord signal-desktop karere
    prismlauncher kicad bambu-studio opencv
    qt6.qtwayland #Required for Qt apps like those above.
    ffmpeg p7zip jq fzf zoxide resvg imagemagick #yazi pkgs
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

  programs.nix-ld.enable = true;

}
