{ config, lib, pkgs, ... }:
let
  swayRemote = pkgs.writeShellScriptBin "sway-remote" ''
    set -euo pipefail
    uid="$(id -u)"
    export XDG_RUNTIME_DIR="/run/user/$uid"
    if pgrep -xu "$USER" sway >/dev/null; then
      echo "Sway is already running."
      exit 0
    fi
    systemctl --user reset-failed sway-remote.service 2>/dev/null || true
    systemd-run --user --unit=sway-remote --collect \
      --property=Type=exec --property=Restart=no \
      --setenv=XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
      ${pkgs.sway}/bin/sway
    echo "Sway launch requested on $(hostname)."
  '';
in
{
  environment.systemPackages = [ swayRemote ];
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

  # Seatd for wlroots compositors (sway)
  services.dbus.enable = true;
  services.seatd.enable = true;
  services.libinput.enable = true; #input driver stack (mice, touchpads, etc.)

  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings.screencast = {
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or";
      };
    };
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.sway = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
    };
  };

  #security
  security.polkit = {
    enable = true;
    enablePkexecWrapper = true;    
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.user == "joel") {
          return polkit.Result.YES;
        }
      });
    '';
  };

  # solaar
  programs.solaar = {
    enable = true;
    #userService.window = show; -> doesn't work right now, in sway
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
    swaylock = {
      enable = true;
      fprintAuth = true;
      unixAuth = true;
    };
  };

  environment.shellAliases = {
    s = "sway-remote";
    S = "/home/joel/.config/sway/scripts/servers/start-servers.sh";
    minecraft-server = "/home/joel/.config/sway/scripts/servers/minecraft-server.py";
    iphone4817 = "ssh iphone4817";
    rt4817 = "ssh joel@rt4817";
    lt4817 = "ssh joel@lt4817";
  };

  # Users
  users.users.joel = {
    linger = true;
    home = lib.mkForce "/home/joel";
    isNormalUser = true;
    isSystemUser = lib.mkForce false;
    extraGroups = [ "wheel" "seat" "networkmanager" "audio" "video" "input" "cdrom" ];
  };

  security.sudo.extraRules = [
    {
      users = [ "joel" ];
      commands = [
        { command = "/run/current-system/sw/bin/timedatectl"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/pkill"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/setsid"; options = [ "NOPASSWD" ]; }
        { command = "/home/joel/.config/sway/scripts/rotate-touchpad.py"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/reset-hyperx-dac"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];
}
