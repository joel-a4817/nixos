
{ config, pkgs, lib, ... }:
#need this to work
let
  # Wrapper scripts so bindings are short & future-proof
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

  # Cursor settings
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    gtk.enable = true;
    x11.enable = true;
  };

  # User packages + the wrapper scripts
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
  ] ++ [ ffMain ffOther ];

  programs.fastfetch.enable = true;

  # === MAIN PRESET: focused & live stats ===
  # Will be written to: ~/.local/share/fastfetch/presets/main.jsonc
  xdg.dataFile."fastfetch/presets/main.jsonc".text = ''
  {
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": "none",
    "display": {
      "separator": " 󰅂 ",
      "color": { "keys": "light_cyan", "title": "light_magenta" },
      "key": { "width": 18, "type": "string" },
      "bar": {
        "width": 18,
        "char": { "elapsed": "■", "total": "·" }   // schema fix
      },
      "percent": { "type": 3, "green": 33, "yellow": 66 }
    },
    "modules": [
      { "type": "title", "key": "Title", "format": "{user-name}@{host-name}", "keyColor": "light_magenta" },

      "break",
      { "type": "custom", "format": "\u001b[90m┌─ System ───────────────────────────────┐" },
      { "type": "datetime", "key": "Date/Time", "keyColor": "light_cyan",
        "format": "{1}-{3}-{11}  {14}:{17}:{20}" },
      { "type": "uptime", "key": "Uptime", "keyColor": "light_cyan" },
      { "type": "users", "key": "Users", "keyColor": "light_cyan" },
      { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

      "break",
      { "type": "custom", "format": "\u001b[90m┌─ CPU & Load ───────────────────────────┐" },
      { "type": "cpu", "key": "CPU", "keyColor": "light_green",
        "format": "{name} ({cores-physical}C/{cores-logical}T) @ {freq-max}" },
      { "type": "cpuCache", "key": "CPU Cache", "keyColor": "light_green" },
      { "type": "cpuUsage", "key": "CPU Usage", "keyColor": "light_green",
        "percent": { "type": 3 } },
      { "type": "loadavg", "key": "Load Avg", "keyColor": "light_green" },
      { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

      "break",
      { "type": "custom", "format": "\u001b[90m┌─ Graphics & Display ───────────────────┐" },
      { "type": "gpu", "key": "GPU", "keyColor": "light_yellow" },
      { "type": "display", "key": "Monitor", "keyColor": "light_yellow" },
      { "type": "brightness", "key": "Brightness", "keyColor": "light_yellow",
        "percent": { "type": 3 } },
      { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

      "break",
      { "type": "custom", "format": "\u001b[90m┌─ Power, Disk & Memory ───────────────────────┐" },
      { "type": "battery", "key": "Battery", "keyColor": "light_blue",
        "percent": { "type": 3 } },
      // ADDED: memory usage module
      { "type": "memory", "key": "Memory", "keyColor": "light_blue",
        "percent": { "type": 3 } },
      { "type": "swap", "key": "Swap", "keyColor": "light_blue",
        "percent": { "type": 3 } },
      { "type": "disk",          "key": "Disk", "keyColor": "light_blue" },
      { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

      "break",
      { "type": "custom", "format": "\u001b[90m┌─ Network ──────────────────────────────┐" },
      { "type": "wifi", "key": "Wi‑Fi", "keyColor": "light_cyan" },
      { "type": "publicIp", "key": "Public IP", "keyColor": "light_cyan" },
      { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

      "break",
      { "type": "custom", "format": "\u001b[90m┌─ Audio & Media ────────────────────────┐" },
      { "type": "sound", "key": "Sound", "keyColor": "light_magenta" },
      { "type": "media", "key": "Now Playing", "keyColor": "light_magenta" },
      { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" }
    ]
  }
  '';

  # === OTHER PRESET: exhaustive system profile ===
  # Will be written to: ~/.local/share/fastfetch/presets/other.jsonc
  xdg.dataFile."fastfetch/presets/other.jsonc".text = ''
  {
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": "none",
    "display": {
      "separator": " → ",
      "color": { "keys": "light_blue", "title": "light_red" },
      "key": { "width": 20, "type": "string" },
      "bar": {
        "width": 18,
        "char": { "elapsed": "█", "total": "░" }   // schema fix
      },
      "percent": { "type": 3, "green": 40, "yellow": 70 }
    },
    "modules": [
      { "type": "title", "key": "Title", "format": "{user-name}@{host-name}", "keyColor": "light_red" },

      "break",
      { "type": "custom", "format": "\u001b[90m┌─ Boot & Firmware ──────────────────────┐" },
      { "type": "bios",        "key": "BIOS", "keyColor": "light_blue" },
      { "type": "board",       "key": "Motherboard", "keyColor": "light_blue" },
      { "type": "bootmgr",     "key": "Boot Manager", "keyColor": "light_blue" },
      { "type": "tpm",         "key": "TPM", "keyColor": "light_blue" },
      { "type": "powerAdapter","key": "Power Adapter", "keyColor": "light_blue" },
      { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

      "break",
      { "type": "custom", "format": "\u001b[90m┌─ Input & Peripherals ──────────────────┐" },
      { "type": "keyboard", "key": "Keyboards", "keyColor": "light_green" },
      { "type": "mouse",    "key": "Mice", "keyColor": "light_green" },
      { "type": "camera",   "key": "Cameras", "keyColor": "light_green" },
      { "type": "cursor",   "key": "Cursor", "keyColor": "light_green" },
      { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

      "break",
      { "type": "custom", "format": "\u001b[90m┌─ Graphics ─────────────────────────────┐" },
      { "type": "gpu",     "key": "GPU", "keyColor": "light_yellow" },
      { "type": "display", "key": "Display", "keyColor": "light_yellow" },
      { "type": "opengl",  "key": "OpenGL", "keyColor": "light_yellow" },
      { "type": "opencl",  "key": "OpenCL", "keyColor": "light_yellow" },
      { "type": "vulkan",  "key": "Vulkan", "keyColor": "light_yellow" },
      { "type": "wallpaper","key": "Wallpaper", "keyColor": "light_yellow" },
      { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

      "break",
      { "type": "custom", "format": "\u001b[90m┌─ Storage ──────────────────────────────┐" },
      { "type": "diskIo",        "key": "Disk I/O", "keyColor": "light_magenta" },
      { "type": "btrfs",         "key": "BTRFS", "keyColor": "light_magenta" },
      { "type": "zpool",         "key": "ZFS Pools", "keyColor": "light_magenta" },
      { "type": "physicalDisk",  "key": "Physical Disk", "keyColor": "light_magenta" },
      { "type": "physicalMemory","key": "Physical Memory", "keyColor": "light_magenta" },
      { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

      "break",
      { "type": "custom", "format": "\u001b[90m┌─ Network ──────────────────────────────┐" },
      { "type": "dns",     "key": "DNS", "keyColor": "light_cyan" },
      { "type": "localIp", "key": "Local IP", "keyColor": "light_cyan" },
      { "type": "netIo",   "key": "Net I/O", "keyColor": "light_cyan" },
      { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" },

      "break",
      { "type": "custom", "format": "\u001b[90m┌─ Software & Session ───────────────────┐" },
      { "type": "os",         "key": "OS", "keyColor": "light_blue" },
      { "type": "kernel",     "key": "Kernel", "keyColor": "light_blue" },
      { "type": "host",       "key": "Host", "keyColor": "light_blue" },
      { "type": "chassis",    "key": "Chassis", "keyColor": "light_blue" },
      { "type": "initSystem", "key": "Init", "keyColor": "light_blue" },
      { "type": "de",         "key": "DE", "keyColor": "light_blue" },
      { "type": "lm",         "key": "Login Manager", "keyColor": "light_blue" },
      { "type": "wm",         "key": "WM", "keyColor": "light_blue" },
      { "type": "packages",   "key": "Packages", "keyColor": "light_blue" },
      { "type": "version",    "key": "Fastfetch", "keyColor": "light_blue" },
      { "type": "editor",     "key": "Editor", "keyColor": "light_blue" },
      { "type": "shell",      "key": "Shell", "keyColor": "light_blue" },
      { "type": "terminal",   "key": "Terminal", "keyColor": "light_blue" },
      { "type": "terminalSize","key": "Terminal Size", "keyColor": "light_blue" },
      { "type": "terminalFont","key": "Terminal Font", "keyColor": "light_blue" },
      { "type": "terminalTheme","key": "Terminal Theme", "keyColor": "light_blue" },
      { "type": "theme",      "key": "DE/WM Theme", "keyColor": "light_blue" },
      { "type": "font",       "key": "Fonts", "keyColor": "light_blue" },
      { "type": "locale",     "key": "Locale", "keyColor": "light_blue" },
      { "type": "processes",  "key": "Processes", "keyColor": "light_blue" },
      { "type": "player",     "key": "Media Player", "keyColor": "light_blue" },
      { "type": "custom", "format": "\u001b[90m└────────────────────────────────────────┘" }
    ]
  }
  '';
}
