{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    wvkbd moonlight-qt
    heimdall-gui android-tools
    snapshot
    clipse
    calcurse
    libreoffice-qt6-fresh hunspell hunspellDicts.en_AU corefonts
    zathura zathuraPkgs.zathura_pdf_mupdf
    discord
    prismlauncher
    signal-desktop
    kicad
    bambu-studio
    opencv
    qt5.qtwayland #Required for Qt apps like those above.
    #yazi pkgs:
    ffmpeg p7zip jq poppler fzf zoxide resvg imagemagick
    trash-cli lazygit fd ripgrep nushell #required by yazi plugins
  ];
}
