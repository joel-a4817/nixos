{ config, pkgs, lib, ... }:
{

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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


  # Boot (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
  
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # dbus-run-session is recommended for Wayland compositors
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet \
            --remember \
            --time \
            --session-wrapper dbus-run-session \
            --cmd ${pkgs.sway}/bin/sway
        '';
        user = "joel";
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

    services.flatpak.enable = true;
    programs.firefox.enable = true;
# Packages
  environment.systemPackages = with pkgs; [
    wget git
    sway wmenu swaybg
    grim slurp wf-recorder wl-clipboard pulseaudio brightnessctl fastfetch imv mpv copyq unzip zip
    solaar
    cloudflare-warp
    speedtest-cli
    curl gsettings-desktop-schemas #for timezones
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

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Allow unfree if you need proprietary packages (you need)
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
}
