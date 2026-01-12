{ config, lib, pkgs, ... }:

let
  pixy2UdevRules = pkgs.stdenvNoCC.mkDerivation {
    pname = "pixy2-udev-rules";
    version = "1";
    src = ./pixy.rules;
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/lib/udev/rules.d
      # name it with a prefix so ordering is sane
      cp "$src" $out/lib/udev/rules.d/99-pixy.rules
    '';
  };
in
{
  # NixOS will collect rule files from packages under {lib,etc}/udev/rules.d
  services.udev.packages = [ pixy2UdevRules ];

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

#start sway with exec sway!!
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
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

programs.neovim = {
  enable = true;
  defaultEditor = true;
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

  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;
    preferencesStatus = "locked";
    preferences = {
      # -------------------------
      # Homepage & session restore
      # -------------------------
      "browser.startup.homepage" = "about:blank";
      "browser.newtabpage.enabled" = false;

      # 3 = Restore previous session
      "browser.startup.page" = 3;

      # -------------------------
      # Default search same in private and normal
      # -------------------------
      "browser.search.separatePrivateDefault" = false;

      # -------------------------
      # Downloads
      # -------------------------
      "browser.download.useDownloadDir" = true;
      "browser.download.always_ask_before_handling_new_types" = false;

      # -------------------------
      # Sidebar visibility (this one wasn't in your blocked list)
      # -------------------------
      "browser.sidebar.show" = true;

      # -------------------------
      # Bookmarks toolbar
      # -------------------------
      "browser.toolbars.bookmarks.visibility" = "newtab";

      # -------------------------
      # userContent.css / userChrome.css
      # -------------------------
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

      # -------------------------
      # Default appearance
      # -------------------------
      "browser.display.background_color" = "#1D1C22";
      "browser.display.foreground_color" = "#FFFFFF";
      "browser.anchor_color" = "#FFFFFF";
      "browser.active_color.dark" = "{}";
      "browser.visited_color" = "#FFFFFF";

      "layout.css.prefers-color-scheme.content-override" = 0;
    };

    # ------------------------------------------------------------------
    # AutoConfig: for prefs blocked by the Enterprise "Preferences" policy
    # ("Preference not allowed for stability reasons")
    #
    # ------------------------------------------------------------------
    autoConfig = ''
     // IMPORTANT: Start your code on the 2nd line

      // -------------------------
      // Privacy (blocked via policy Preferences)
      // -------------------------
      lockPref("privacy.resistFingerprinting", false);

      lockPref("privacy.clearOnShutdown_v2.cache", false);
      lockPref("privacy.clearOnShutdown_v2.cookiesAndStorage", false);

      lockPref("privacy.trackingprotection.allow_list.convenience.enabled", true);
      lockPref("privacy.trackingprotection.allow_list.baseline.enabled", true);

      // -------------------------
      // Sidebar / vertical tabs (blocked via policy Preferences)
      // -------------------------
      lockPref("sidebar.revamp", true);
      lockPref("sidebar.verticalTabs", true);

      lockPref("sidebar.newTool.migration.bookmarks", "{}");
      lockPref("sidebar.newTool.migration.history", "{}");
      lockPref("sidebar.hideTabsAndSidebar", false);

      // -------------------------
      // Advanced Fonts (blocked via policy Preferences)
      // -------------------------
      lockPref("font.default.x-western", "sans-serif");
      lockPref("font.default.x-unicode", "sans-serif");

      lockPref("font.name.serif.x-western", "JetBrainsMono Nerd Font");
      lockPref("font.name.sans-serif.x-western", "JetBrainsMono Nerd Font");
      lockPref("font.name.monospace.x-western", "JetBrainsMono Nerd Font");

      lockPref("font.name.serif.x-unicode", "JetBrainsMono Nerd Font");
      lockPref("font.name.sans-serif.x-unicode", "JetBrainsMono Nerd Font");
      lockPref("font.name.monospace.x-unicode", "JetBrainsMono Nerd Font");

      lockPref("browser.display.use_document_fonts", 0);

      lockPref("font.minimum-size.x-western", 16);
      lockPref("font.minimum-size.x-unicode", 16);

      lockPref("font.size.variable.x-western", 16);
      lockPref("font.size.fixed.x-western", 16);
      lockPref("font.size.variable.x-unicode", 16);
      lockPref("font.size.fixed.x-unicode", 16);
    '';

    # Policies for extension installation (Enterprise managed)
    policies = {
      SearchEngines = {
        Default = "DuckDuckGo";
        PreventInstalls = true;
      };
      ExtensionSettings = {
        # uBlock Origin (force installed)
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };

        # Dark Reader (force installed)
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
      };
    };
  };

  # -----------------------------------------------------------------
  # This below is different, but works so keep.
  # -----------------------------------------------------------------

  environment.etc."librewolf/policies/policies.json".source =
    config.environment.etc."firefox/policies/policies.json".source;



# Packages
environment.systemPackages = with pkgs; [
  wget git gh #need gh to stay logged in
  wmenu swaybg autotiling
  grim slurp wf-recorder
  pulseaudio brightnessctl
  imv mpv unzip zip 
  clipse wl-clipboard
  appimage-run
];


  #warp  
  services.cloudflare-warp = {
    enable = true;
    openFirewall = true;
  };

  #Printing
services.avahi = {
  enable = true;
  nssmdns4 = true;
};

services.printing = {
  enable = true;
  drivers = with pkgs; [
    cups-filters
    cups-browsed
  ];
};

hardware.printers = {
  ensureDefaultPrinter = "BrotherPrinterHome";
  ensurePrinters = [
    {
      deviceUri = "dnssd://Brother%20MFC-L2750DW%20series._ipp._tcp.local/?uuid=e3248000-80ce-11db-8000-3c2af4f6c121";
      location = "home";
      name = "BrotherPrinterHome";
      model = "everywhere";
    }
  ];
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

  # xdg portal enabling (wayland needs because everything is locked down and secure by default. To allow screen to be seen by apps this is needed).
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
