{ config, lib, pkgs, ... }:

let
  # qutebrowser with WideVine enabled
  qutebrowser-widevine = pkgs.qutebrowser.override {
    enableWideVine = true;
  };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  environment.shellAliases = {
    s = "exec sway";
  };

  # Packages
  environment.systemPackages = with pkgs; [
    (pkgs.python3.withPackages (ps: with ps; [ evdev ]))
    qutebrowser-widevine
    wget git gh
    wmenu swaybg autotiling
    grim slurp wf-recorder wl-clipboard
    pulseaudio brightnessctl
    imv mpv unzip zip
    appimage-run
  ];

  nixpkgs.config.allowUnfree = true;
}
