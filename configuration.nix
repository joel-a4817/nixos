{ config, lib, pkgs, ... }:
#checking if works
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
  #time.timeZone = "Australia/Melbourne"; #not needed since to set timezone sets /etc/localtime

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

# https://github.com/apognu/tuigreet
services.greetd = {
  enable = true;
  settings = {
    default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --remember-session --time";
      user = "greeter";
    };
  };
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
    window = "hide"; # Show the window on startup (show, *hide*, only [window only])
#   batteryIcons = "regular"; # Which battery icons to use (*regular*, symbolic, solaar)
    extraArgs = "--headless"; # Extra arguments to pass to solaar on startup
  };

#flatpak with flathub https://nixos.wiki/wiki/Flatpak
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
    programs.firefox.enable = true;
# Packages

environment.systemPackages = with pkgs; [
  wget git
  wmenu swaybg
  grim slurp wf-recorder wl-clipboard pulseaudio brightnessctl imv mpv unzip zip
  clipse
  solaar
  cloudflare-warp
  speedtest-cli
  curl gsettings-desktop-schemas
  autotiling
  gh
];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

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
 #     deviceUri = "ipp://<printer-ip>/ipp/print";  # replace with your printer IP
 #     model = "everywhere";                        # same as lpadmin -m everywhere
 #     enabled = true;                              # same as -E
 #   };
 # };

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
  enable = true;        # ensure the PAM service exists
  fprintAuth = true;    # attach pam_fprintd.so to swaylock's auth chain
};

  # OpenGL - wlroots like sway needs
  hardware.graphics.enable = true;

  # xdg portal enabling
xdg.portal = {
  enable = true;

  # Install actual backends (required when enable = true)
  extraPortals = with pkgs; [
    xdg-desktop-portal-wlr   # Wayland screencast/screenshot for wlroots
    xdg-desktop-portal-gtk   # Generic fallback (OpenURI, file chooser, etc.)
  ];

  # Post-1.17: explicitly choose which backend handles which interface
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
