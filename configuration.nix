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
      command = "${pkgs.tuigreet}/bin/tuigreet --remember --remember-session --time";
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
  wget git
  wmenu swaybg autotiling
  grim slurp wf-recorder
  pulseaudio brightnessctl
  imv mpv unzip zip 
  clipse wl-clipboard
  appimage-run
  fd ripgrep #required by neovim (telescope) and yazi.
];
 

programs.neovim = {
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;

  configure = {
    packages.myPlugins = with pkgs.vimPlugins; {
      start = [
        telescope-nvim
        plenary-nvim
        telescope-fzf-native-nvim
      ];
      opt = [ ];
    };
    customRC = ''
      lua << 'LUA'
      vim.g.mapleader = " "

      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.termguicolors = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.signcolumn = "yes"

      vim.cmd [[
        hi Normal guibg=NONE ctermbg=NONE
        hi NormalNC guibg=NONE ctermbg=NONE
        hi NonText guibg=NONE ctermbg=NONE
      ]]

      require("telescope").setup({
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })
      require("telescope").load_extension("fzf")

      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }
      local builtin = require("telescope.builtin")

      map("n", "<leader>ff", builtin.find_files, opts)
      map("n", "<leader>fg", builtin.live_grep, opts)
      map("n", "<leader>fb", builtin.buffers, opts)
      map("n", "<leader>fh", builtin.help_tags, opts)

      map("n", "<leader>gc", builtin.git_commits,  { desc = "Git commits" })
      map("n", "<leader>gC", builtin.git_bcommits, { desc = "Git commits (file)" })
      map("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
      map("n", "<leader>gs", builtin.git_status,   { desc = "Git status" })
      map("n", "<leader>gS", builtin.git_stash,    { desc = "Git stash" })

      map("n", "<leader>mm", ":set modifiable<CR>", opts)
      LUA
    '';
  };
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
