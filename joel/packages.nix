{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    localsend yt-dlp
    ungoogled-chromium poppler-utils #svg -> pdf 
    anki
    heimdall-gui android-tools
    kdePackages.kamoso
    clipse calcurse
    collabora-desktop
    discord signal-desktop karere
    prismlauncher kicad bambu-studio opencv
    qt6.qtwayland #Required for Qt apps like those above.
    ffmpeg p7zip jq fzf zoxide resvg imagemagick #yazi pkgs
    trash-cli lazygit fd ripgrep nushell #required by yazi plugins
  ];
}
