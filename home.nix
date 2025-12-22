{ config, pkgs, lib, ... }:

let
  ffMain = pkgs.writeShellScriptBin "ff-main" ''
    exec fastfetch -c main -l none
  '';

  ffOther = pkgs.writeShellScriptBin "ff-other" ''
    exec fastfetch -c other -l none
  '';
in
{
  home.username = "joel";
  home.homeDirectory = "/home/joel";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.pointerCursor = {
  name = "Bibata-Modern-Classic";
  package = pkgs.bibata-cursors;
  gtk.enable = true;
  x11.enable = true;
};

  home.packages = with pkgs; [
    fastfetch
    prismlauncher
    signal-desktop
    vscode
    kicad
    prusa-slicer
    bambu-studio
    opencv
    qt5.qtwayland
    ffMain
    ffOther
  ];

  programs.fastfetch.enable = true;

  # ======================
  # MAIN FASTFETCH PRESET
  # ======================
  xdg.dataFile."fastfetch/presets/main.jsonc".text = ''
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": "none",
  "display": {
    "separator": " 󰅂 ",
    "color": { "keys": "light_cyan", "title": "light_magenta" },
    "key": { "width": 18, "type": "string" },
    "bar": { "width": 18 },
    "percent": { "type": 3 }
  },
  "modules": [
    { "type": "title", "format": "{user-name}@{host-name}" },

    { "type": "custom", "format": "\u001b[90m┌─ System ───────────────────────────────┐" },
    { "type": "datetime", "key": "Date/Time", "format": "{1}-{3}-{11}  {14}:{17}:{20}" },
    { "type": "uptime", "key": "Uptime" },
    { "type": "users", "key": "Users" },
    { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

    { "type": "custom", "format": "\u001b[90m┌─ CPU & Load ───────────────────────────┐" },
    { "type": "cpu", "key": "CPU", "format": "{name} ({cores-physical}C/{cores-logical}T) @ {freq-max}" },
    { "type": "cpuCache", "key": "CPU Cache" },
    { "type": "cpuUsage", "key": "CPU Usage" },
    { "type": "loadavg", "key": "Load Avg" },
    { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

    { "type": "custom", "format": "\u001b[90m┌─ Graphics & Display ───────────────────┐" },
    { "type": "gpu", "key": "GPU" },
    { "type": "display", "key": "Monitor" },
    { "type": "brightness", "key": "Brightness" },
    { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

    { "type": "custom", "format": "\u001b[90m┌─ Storage ──────────────────────────────┐" },
    { "type": "disk", "key": "Disk" },
    { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

    { "type": "custom", "format": "\u001b[90m┌─ Power & Memory ───────────────────────┐" },
    { "type": "battery", "key": "Battery" },
    { "type": "memory", "key": "Memory" },
    { "type": "swap", "key": "Swap" },
    { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

    { "type": "custom", "format": "\u001b[90m┌─ Network ──────────────────────────────┐" },
    { "type": "wifi", "key": "Wi-Fi" },
    { "type": "publicIp", "key": "Public IP" },
    { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

    { "type": "custom", "format": "\u001b[90m┌─ Audio & Media ────────────────────────┐" },
    { "type": "sound", "key": "Sound" },
    { "type": "media", "key": "Now Playing" },
    { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" }
  ]
}
'';

  # ======================
  # OTHER FASTFETCH PRESET
  # ======================
  xdg.dataFile."fastfetch/presets/other.jsonc".text = ''
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": "none",
  "display": {
    "separator": " → ",
    "color": { "keys": "light_blue", "title": "light_red" },
    "key": { "width": 20, "type": "string" },
    "bar": { "width": 18 },
    "percent": { "type": 3 }
  },
  "modules": [
    { "type": "title", "format": "{user-name}@{host-name}" },

    { "type": "custom", "format": "\u001b[90m┌─ Boot & Firmware ──────────────────────┐" },
    { "type": "bios" },
    { "type": "board" },
    { "type": "bootmgr" },
    { "type": "tpm" },
    { "type": "powerAdapter" },
    { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

    { "type": "custom", "format": "\u001b[90m┌─ Input & Peripherals ──────────────────┐" },
    { "type": "keyboard" },
    { "type": "mouse" },
    { "type": "camera" },
    { "type": "cursor" },
    { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

    { "type": "custom", "format": "\u001b[90m┌─ Graphics ─────────────────────────────┐" },
    { "type": "gpu" },
    { "type": "display" },
    { "type": "opengl" },
    { "type": "opencl" },
    { "type": "vulkan" },
    { "type": "wallpaper" },
    { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

    { "type": "custom", "format": "\u001b[90m┌─ Storage ──────────────────────────────┐" },
    { "type": "diskIo" },
    { "type": "btrfs" },
    { "type": "zpool" },
    { "type": "physicalDisk" },
    { "type": "physicalMemory" },
    { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

    { "type": "custom", "format": "\u001b[90m┌─ Network ──────────────────────────────┐" },
    { "type": "dns" },
    { "type": "localIp" },
    { "type": "netIo" },
    { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

    { "type": "custom", "format": "\u001b[90m┌─ Software & Session ───────────────────┐" },
    { "type": "os" },
    { "type": "kernel" },
    { "type": "host" },
    { "type": "chassis" },
    { "type": "initSystem" },
    { "type": "de" },
    { "type": "lm" },
    { "type": "wm" },
    { "type": "packages" },
    { "type": "version" },
    { "type": "editor" },
    { "type": "shell" },
    { "type": "terminal" },
    { "type": "terminalSize" },
    { "type": "terminalFont" },
    { "type": "terminalTheme" },
    { "type": "theme" },
    { "type": "font" },
    { "type": "locale" },
    { "type": "processes" },
    { "type": "player" },
    { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" }
  ]
}
'';
}

