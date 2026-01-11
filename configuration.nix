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

  # This controls how NixOS marks the generated Preferences policy entries.
  # "locked" = cannot be changed in the UI (matches what you're doing now).
  preferencesStatus = "locked";  # [1](https://codeberg.org/librewolf/settings)

  # Your "mozilla.cfg" prefs go here as a plain attrset.
  # NixOS converts this to a Firefox enterprise policy "Preferences" block automatically. [1](https://codeberg.org/librewolf/settings)
  preferences = {
    # -------------------------
    # Privacy
    # -------------------------
    "privacy.resistFingerprinting" = false;

    # Your clear-on-shutdown v2 prefs:
    "privacy.clearOnShutdown_v2.cache" = false;
    "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;

    # WebCompat exceptions tiers (FF 142+)
    "privacy.trackingprotection.allow_list.convenience.enabled" = true;
    "privacy.trackingprotection.allow_list.baseline.enabled" = true;

    # -------------------------
    # Homepage & session restore
    # -------------------------
    "browser.startup.homepage" = "about:blank";
    "browser.newtabpage.enabled" = false;

    # 3 = Restore previous session
    "browser.startup.page" = 3;

    # -------------------------
    # Default search
    # -------------------------
    "browser.newtabpage.activity-stream.trendingSearch.defaultSearchEngine" = "DuckDuckGo";

    # NOTE: you had "seperate" in your file. The actual pref is "separate".
    "browser.search.separatePrivateDefault" = false;

    # -------------------------
    # Downloads
    # -------------------------
    "browser.download.useDownloadDir" = true;
    "browser.download.always_ask_before_handling_new_types" = false;

    # -------------------------
    # Sidebar / vertical tabs
    # -------------------------
    # For Firefox vertical tabs / revamped sidebar, the common controlling prefs include:
    # - sidebar.revamp
    # - sidebar.verticalTabs
    # per Mozilla/Firefox docs and community references. [2](https://support.mozilla.org/en-US/kb/use-sidebar-access-tools-and-vertical-tabs)[3](https://winaero.com/firefox-enable-vertical-tabs/)[4](https://www.askvg.com/tips-tweak-and-customize-firefox-sidebar-and-vertical-tabs-like-a-pro/)
    "sidebar.revamp" = true;
    "sidebar.verticalTabs" = true;

    # Your additional sidebar prefs (as provided):
    "browser.sidebar.show" = true;
    "sidebar.newTool.migration.bookmarks" = "{}";
    "sidebar.newTool.migration.history" = "{}";
    "sidebar.hideTabsAndSidebar" = false;

    "browser.toolbars.bookmarks.visibility" = "newtab";

    # -------------------------
    # userContent.css / userChrome.css
    # -------------------------
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

    # -------------------------
    # Default appearance
    # -------------------------
    "browser.display.document_color_use" = 2;
    "browser.display.background_color" = "#1D1C22";
    "browser.display.foreground_color" = "#FFFFFF";
    "browser.anchor_color" = "#FFFFFF";
    "browser.active_color.dark" = "{}";
    "browser.visited_color" = "#FFFFFF";

    "layout.css.prefers-color-scheme.content-override" = 0;

    # -------------------------
    # Advanced Fonts (Text settings)
    # -------------------------
    "font.default.x-western" = "sans-serif";
    "font.default.x-unicode" = "sans-serif";

    "font.name.serif.x-western" = "JetBrainsMono Nerd Font";
    "font.name.sans-serif.x-western" = "JetBrainsMono Nerd Font";
    "font.name.monospace.x-western" = "JetBrainsMono Nerd Font";

    "font.name.serif.x-unicode" = "JetBrainsMono Nerd Font";
    "font.name.sans-serif.x-unicode" = "JetBrainsMono Nerd Font";
    "font.name.monospace.x-unicode" = "JetBrainsMono Nerd Font";

    "browser.display.use_document_fonts" = 0;

    "font.minimum-size.x-western" = 16;
    "font.minimum-size.x-unicode" = 16;

    "font.size.variable.x-western" = 16;
    "font.size.fixed.x-western" = 16;
    "font.size.variable.x-unicode" = 16;
    "font.size.fixed.x-unicode" = 16;
  };

  # Policies are for things Firefox treats as "enterprise managed" like extension installation.
  policies = {
    ExtensionSettings = {
      "addon@darkreader.org" = {
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        installation_mode = "force_installed";
      };
    };
  };
};

environment.etc."firefox/policies/policies.json".target = "librewolf/policies/policies.json";

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
