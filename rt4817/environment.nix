{ config, lib, pkgs, ... }:
let
  swayLaunch = pkgs.writeShellApplication {
    name = "sway-launch";
    runtimeInputs = with pkgs; [ coreutils sway systemd ];
    text = ''
      set -Eeuo pipefail
      current_tty="$(tty 2>/dev/null || true)"

      # A physical TTY login already owns seat0, so preserve the original,
      # direct launch path.
      if [[ -z "''${SSH_CONNECTION:-}" && "$current_tty" == /dev/tty* ]]; then
        exec sway
      fi

      # SSH/iSH sessions do not own seat0. Ask systemd to create a real
      # PAM/login session on tty7; that session then execs Sway below.
      exec /run/wrappers/bin/sudo -n \
        /run/current-system/sw/bin/systemctl start --no-block sway-tty-session.service
    '';
  };
in
{
  environment.systemPackages = [ swayLaunch ];


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

  environment.loginShellInit = ''
    if [ "$(tty 2>/dev/null || true)" = /dev/tty7 ] \
      && [ -O /run/sway-tty-session-joel ]; then
      rm -f /run/sway-tty-session-joel
      exec sway
    fi
  '';

  environment.shellAliases = {
    s = "sway-launch";
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

  # SSH/iSH launch path: open a genuine local login session on tty7.
  # login(1) runs the normal PAM stack, so logind assigns seat0 and applies
  # local-session ACLs used by backlight, fingerprint, polkit and input access.
  systemd.services.sway-tty-session = {
    description = "Local Sway login session requested over SSH";
    conflicts = [ "getty@tty7.service" ];
    after = [ "systemd-user-sessions.service" "seatd.service" ];

    path = with pkgs; [ coreutils kbd shadow systemd util-linux ];

    serviceConfig = {
      Type = "simple";
      ExecStartPre = "+${pkgs.writeShellScript "prepare-sway-tty-session" ''
        install -o joel -g users -m 600 /dev/null /run/sway-tty-session-joel
      ''}";
      ExecStart = "${pkgs.writeShellScript "run-sway-tty-login" ''
        exec openvt -c 7 -f -s -w -- login -f joel
      ''}";
      ExecStopPost = "+${pkgs.writeShellScript "cleanup-sway-tty-session" ''
        rm -f /run/sway-tty-session-joel
        systemctl start getty@tty7.service || true
      ''}";
      KillMode = "mixed";
      TimeoutStartSec = "15s";
      TimeoutStopSec = "15s";
      Restart = "no";
    };
  };

  security.sudo.extraRules = [
    {
      users = [ "joel" ];
      commands = [
        { command = "/run/current-system/sw/bin/timedatectl"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/pkill"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl start --no-block sway-tty-session.service"; options = [ "NOPASSWD" ]; }
        { command = "/home/joel/.config/sway/scripts/rotate-touchpad.py"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/reset-hyperx-dac"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];
}
