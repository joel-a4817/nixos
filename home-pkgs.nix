{ config, pkgs, lib, ... }:

let
  sudo-yazi-fixed = pkgs.yaziPlugins.sudo.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      plugin_file="$(find . -name main.lua -print -quit)"

      substituteInPlace "$plugin_file" \
        --replace-fail \
          'for _, url in pairs(cx.yanked) do' \
          'for _, file in pairs(cx.yanked) do'

      substituteInPlace "$plugin_file" \
        --replace-fail \
          'table.insert(yanked, tostring(url))' \
          'table.insert(yanked, tostring(file.url))'
    '';
  });
in
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
      sudo = sudo-yazi-fixed; #https://github.com/TD-Sky/sudo.yazi
      lazygit = pkgs.yaziPlugins.lazygit; #https://github.com/Lil-Dank/lazygit.yazi
      recycle-bin = pkgs.yaziPlugins.recycle-bin; #https://github.com/uhs-robert/recycle-bin.yazi
      restore = pkgs.yaziPlugins.restore; #https://github.com/boydaihungst/restore.yazi
    };
  };
}
