{ config, lib, pkgs, ... }:
let
  swaySession = pkgs.writeShellApplication {
    name = "sway-session";
    runtimeInputs = with pkgs; [ coreutils kbd procps systemd ];
    text = ''
      set -Eeuo pipefail

      if [[ "''${1:-start}" == "stop" ]]; then
        exec sudo systemctl stop sway-session.service
      fi

      if systemctl is-active --quiet sway-session.service; then
        exec sudo chvt 2
      fi

      sudo systemctl start sway-session.service
      exec sudo chvt 2
    '';
  };
in
{
  environment.systemPackages = [ swaySession ];

  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];
    };
    packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
  };

  services.dbus.enable = true;
  services.seatd.enable = true;
  services.libinput.enable = true;

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

  programs.solaar.enable = true;
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
    s = "sway-session";
    S = "/home/joel/.config/sway/scripts/servers/start-servers.sh";
    minecraft-server = "/home/joel/.config/sway/scripts/servers/minecraft-server.py";
    iphone4817 = "ssh iphone4817";
    rt4817 = "ssh joel@rt4817";
    lt4817 = "ssh joel@lt4817";
  };

  users.users.joel = {
    linger = true;
    home = lib.mkForce "/home/joel";
    isNormalUser = true;
    isSystemUser = lib.mkForce false;
    extraGroups = [ "wheel" "seat" "networkmanager" "audio" "video" "input" "cdrom" ];
  };

  systemd.services.sway-session = {
    description = "Joel Sway session on tty2";
    conflicts = [ "getty@tty2.service" ];
    after = [ "systemd-user-sessions.service" "getty@tty1.service" ];
    wants = [ "systemd-user-sessions.service" ];

    serviceConfig = {
      Type = "simple";
      User = "joel";
      Group = "users";
      PAMName = "login";
      TTYPath = "/dev/tty2";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
      StandardInput = "tty-force";
      StandardOutput = "journal+console";
      StandardError = "journal+console";
      UtmpIdentifier = "tty2";
      UtmpMode = "user";
      WorkingDirectory = "/home/joel";
      Environment = [
        "HOME=/home/joel"
        "USER=joel"
        "LOGNAME=joel"
        "XDG_SESSION_TYPE=wayland"
        "XDG_CURRENT_DESKTOP=sway"
        "XDG_SESSION_DESKTOP=sway"
      ];
      ExecStart = "/run/current-system/sw/bin/sway";
      Restart = "no";
    };
  };

  security.sudo.extraRules = [
    {
      users = [ "joel" ];
      commands = [
        { command = "/run/current-system/sw/bin/timedatectl"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/pkill"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/chvt"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl start sway-session.service"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl stop sway-session.service"; options = [ "NOPASSWD" ]; }
        { command = "/home/joel/.config/sway/scripts/rotate-touchpad.py"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/reset-hyperx-dac"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];
}
