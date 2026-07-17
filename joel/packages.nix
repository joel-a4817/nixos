{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    localsend
    ungoogled-chromium poppler-utils #svg -> pdf 
    anki
    heimdall-gui android-tools
    kdePackages.kamoso
    clipse calcurse
    collabora-desktop
    discord signal-desktop karere
    prismlauncher freecad kicad bambu-studio opencv
    qt6.qtwayland #Required for Qt apps like those above.
    #yazi pkgs:
    ffmpeg p7zip jq fzf zoxide resvg imagemagick
    trash-cli lazygit fd ripgrep nushell #required by yazi plugins
  ];
}
