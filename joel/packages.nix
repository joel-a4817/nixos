{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    chromium excalifont poppler-utils 
    anki
    wvkbd moonlight-qt
    heimdall-gui android-tools
    kdePackages.kamoso
    clipse calcurse
    collabora-desktop
    discord signal-desktop karere
    prismlauncher
    kicad bambu-studio opencv
    qt6.qtwayland #Required for Qt apps like those above.
    #yazi pkgs:
    ffmpeg p7zip jq fzf zoxide resvg imagemagick
    trash-cli lazygit fd ripgrep nushell #required by yazi plugins
  ];
}
