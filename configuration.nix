{ config, lib, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports = 
    [ # Include the results of the hardware scan..nix
      ./hardware-configuration.nix
    ];

  # Boot (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "rt4817";

  security.sudo.extraRules = [
    {
      users = [ "joel" ];
      commands = [
        { command = "/run/current-system/sw/bin/timedatectl"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

  # Users
  users.users.joel = {
    isNormalUser = true;
    extraGroups = [ "wheel" "seat" "networkmanager" "audio" "video" ];
    packages = with pkgs; [
      tree
    ];
  };

  # Networking
  networking.networkmanager.enable = true;
  hardware.enableAllFirmware = true;

  # Audio (PipeWire + WirePlumber)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
    
  # Seatd for wlroots compositors (sway); polkit for permissions
  security.polkit.enable = true;
  services.dbus.enable = true;
  services.seatd.enable = true;
  programs.xwayland.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

systemd.user.services.sway = {
  wantedBy = [ "default.target" ];
  serviceConfig.ExecStart = "${pkgs.sway}/bin/sway";
};

services.getty = {
  autologinUser = "joel";
  autologinOnce = true;
};

#virtualbox https://wiki.nixos.org/wiki/VirtualBox
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };
  users.extraGroups.vboxusers.members = [ "joel" ];

#solaar https://github.com/Svenum/Solaar-Flake
  services.solaar = {
    enable = true; # Enable the service
    package = pkgs.solaar; # The package to use
    window = "show"; # Show the window on startup (show, *hide*, only [window only])
#   batteryIcons = "regular"; # Which battery icons to use (*regular*, symbolic, solaar)
    extraArgs = "--headless"; # Extra arguments to pass to solaar on startup
  };

fonts = {
  enableDefaultPackages = true;
  fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };
  packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
};

  programs.firefox.enable = true;
# Packages
environment.systemPackages = with pkgs; [
  (vim.override { clipboardSupport = true; })
  wget git
  wmenu swaybg autotiling
  grim slurp wf-recorder
  pulseaudio brightnessctl
  imv mpv unzip zip 
  clipse wl-clipboard xclip # (vim clipboard in xwayland)
  appimage-run
];

  #warp  
  services.cloudflare-warp = {
    enable = true;
    openFirewall = true;
  };

  # Printing + Avahi for mDNS/IPP
  services.avahi.enable = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.cups-filters ]; # for 'everywhere' model

 # services.printing.printers = {
 #   BrotherPrinter = {
 #     deviceUri = "ipp://<printer-ip>/ipp/print"; # replace with your printer IP
 #     model = "everywhere"; # same as lpadmin -m everywhere
 #     enabled = true; # same as -E
 #   };
 # };

  programs.vim = {
    enable = true;
    defaultEditor = true;
    extraConfig = ''
      " --- Leader key ---
      let mapleader=" "

      " --- UI ---
      set number
      set relativenumber
      set termguicolors
      set signcolumn=yes

      " --- Indentation ---
      set expandtab
      set shiftwidth=2
      set tabstop=2

      " --- Clipboard ---
      set clipboard=unnamedplus

      " --- Transparent background ---
      highlight Normal      guibg=NONE ctermbg=NONE
      highlight NormalNC    guibg=NONE ctermbg=NONE
      highlight NonText     guibg=NONE ctermbg=NONE

      " --- Mouse: scroll WITHOUT moving cursor, but clicking still moves cursor ---
      set mouse=a
      set mousemodel=popup_setpos

      " --- Delete without copying (black-hole) ---
      nnoremap d  "_d
      xnoremap d  "_d
      nnoremap dd "_dd

      " --- Cut entire line to system clipboard (dx) ---
      nnoremap dx "+dd

      " --- Sane defaults ---
      set ttyfast
      set incsearch
      set hlsearch
      set ignorecase
      set smartcase
      set hidden
      set noswapfile
      set backspace=indent,eol,start
      set scrolloff=10
    '';
  };

  # Fprintd
  services.fprintd.enable = true;
  security.pam.services = {
    system-local-login.fprintAuth = true;
    su.fprintAuth = true;
    system-auth.fprintAuth = true;
    login.fprintAuth = true;
    sudo.fprintAuth = true;
    greetd.fprintAuth = true;
  };

security.pam.services.swaylock = {
  enable = true; # ensure the PAM service exists
  fprintAuth = true; # attach pam_fprintd.so to swaylock's auth chain
  unixAuth = true; # password fallback
};

  # OpenGL - wlroots like sway need
  hardware.graphics.enable = true;

  # xdg portal enabling (wayland needs because everything is locked down and secure by default. To allow screen to be seen by apps this is needed.
xdg.portal = {
  enable = true;

  # Install actual backends (required when enable = true)
  extraPortals = with pkgs; [
    xdg-desktop-portal-wlr   # screenshot/screen-recording in sway
    xdg-desktop-portal-gtk   # file chooser in firefox, etc.
  ];

  #post 1.17: explicitly choose which backend portal above handles which interface
  config = {
    common = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
    };
  };
};

  # Allow unfree if you need proprietary packages (you need)
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
}
