{ config, lib, pkgs, ... }:
let
  swaySession = pkgs.writeShellApplication {
    name = "sway-session";
    runtimeInputs = with pkgs; [ systemd ];
    text = ''
      set -Eeuo pipefail
      action="''${1:-start}"
      case "$action" in
        start)
          if ! /run/wrappers/bin/sudo /run/current-system/sw/bin/systemctl start sway-session.service; then
            systemctl status sway-session.service --no-pager >&2 || true
            exit 1
          fi
          systemctl is-active --quiet sway-session.service || {
            systemctl status sway-session.service --no-pager >&2 || true
            exit 1
          }
          exec /run/wrappers/bin/sudo /run/current-system/sw/bin/chvt 2
          ;;
        stop)
          exec /run/wrappers/bin/sudo /run/current-system/sw/bin/systemctl stop sway-session.service
          ;;
        status)
          exec systemctl status sway-session.service --no-pager
          ;;
        *)
          echo "Usage: sway-session [start|stop|status]" >&2
          exit 2
          ;;
      esac
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
    description = "Joel Sway login session on tty2";
    conflicts = [ "getty@tty2.service" ];
    after = [ "systemd-user-sessions.service" "getty@tty1.service" ];
    wants = [ "systemd-user-sessions.service" ];

    path = with pkgs; [ systemd coreutils sudo ];
    environment = {
      HOME = "/home/joel";
      USER = "joel";
      LOGNAME = "joel";
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_DESKTOP = "sway";
      WAYLAND_DISPLAY = "wayland-sway-session";
    };

    serviceConfig = {
      Type = "exec";
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
      ExecStart = "${pkgs.writeShellScript "sway-login-session" ''
        set -Eeuo pipefail
        export XDG_RUNTIME_DIR="/run/user/$(id -u)"
        export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
        export WAYLAND_DISPLAY=wayland-sway-session
        rm -f -- \
          "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" \
          "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY.lock"
        dbus-update-activation-environment --systemd \
          HOME USER LOGNAME PATH \
          XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS \
          XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP
        exec sway
      ''}";
      ExecStartPost = "${pkgs.writeShellScript "sway-session-ready" ''
        set -Eeuo pipefail
        uid=$(${pkgs.coreutils}/bin/id -u joel)
        mainpid=$(systemctl show --property MainPID --value sway-session.service)
        case "$mainpid" in
          ""|0|*[!0-9]*) echo "Invalid Sway MainPID: $mainpid" >&2; exit 1 ;;
        esac
        runtime="/run/user/$uid"
        socket="$runtime/wayland-sway-session"
        for _ in $(${pkgs.coreutils}/bin/seq 1 240); do
          ipc_socket="$runtime/sway-ipc.$uid.$mainpid.sock"
          if [ -S "$socket" ] && [ -S "$ipc_socket" ]; then
            exit 0
          fi
          ${pkgs.coreutils}/bin/sleep 0.05
        done
        echo "Sway sockets did not become ready: $socket and $ipc_socket" >&2
        exit 1
      ''}";
      ExecStopPost = "+${pkgs.writeShellScript "sway-session-cleanup" ''
        uid=$(${pkgs.coreutils}/bin/id -u joel)
        runtime="/run/user/$uid"
        sudo -u joel env XDG_RUNTIME_DIR="$runtime" DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime/bus" \
          systemctl --user stop graphical-session.target || true
        sudo -u joel env XDG_RUNTIME_DIR="$runtime" DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime/bus" \
          systemctl --user unset-environment SWAYSOCK WAYLAND_DISPLAY || true
        rm -f -- "$runtime/wayland-sway-session" "$runtime/wayland-sway-session.lock"
        systemctl start getty@tty2.service
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
        { command = "/run/current-system/sw/bin/chvt"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl start sway-session.service"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl stop sway-session.service"; options = [ "NOPASSWD" ]; }
        { command = "/home/joel/.config/sway/scripts/rotate-touchpad.py"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/reset-hyperx-dac"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];
}
