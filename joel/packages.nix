{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    waydroid-helper
    anki
    wvkbd moonlight-qt
    heimdall-gui android-tools
    kdePackages.kamoso
    clipse
    calcurse
    libreoffice-qt6-fresh hunspell hunspellDicts.en_AU corefonts
    discord signal-desktop karere
    prismlauncher
    kicad
    bambu-studio
    opencv
    qt6.qtwayland #Required for Qt apps like those above.
    #yazi pkgs:
    ffmpeg p7zip jq poppler fzf zoxide resvg imagemagick
    trash-cli lazygit fd ripgrep nushell #required by yazi plugins
  ];
}
