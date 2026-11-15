{ config, lib, pkgs, ... }:
let
  swayRemote = pkgs.writeShellScriptBin "sway-remote" ''
    set -euo pipefail

    uid="$(${pkgs.coreutils}/bin/id -u)"
    runtime="/run/user/$uid"
    export XDG_RUNTIME_DIR="$runtime"
    export DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime/bus"
    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP=sway
    export XDG_CURRENT_DESKTOP=sway

    if [ ! -d "$runtime" ] || [ ! -S "$runtime/bus" ]; then
      echo "The user systemd/DBus session is unavailable at $runtime." >&2
      echo "Check: loginctl user-status $USER" >&2
      exit 1
    fi

    if ${pkgs.procps}/bin/pgrep -xu "$USER" -x sway >/dev/null; then
      echo "Sway is already running on $(hostname)."
      exit 0
    fi

    # Remove a completed/failed transient unit left by an earlier remote launch.
    ${pkgs.systemd}/bin/systemctl --user stop sway-remote.service 2>/dev/null || true
    ${pkgs.systemd}/bin/systemctl --user reset-failed sway-remote.service 2>/dev/null || true

    ${pkgs.systemd}/bin/systemd-run --user \
      --unit=sway-remote \
      --collect \
      --property=Type=exec \
      --property=Restart=no \
      --property=StandardInput=null \
      --property=StandardOutput=journal \
      --property=StandardError=journal \
      --setenv=XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
      --setenv=DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
      --setenv=XDG_SESSION_TYPE=wayland \
      --setenv=XDG_SESSION_DESKTOP=sway \
      --setenv=XDG_CURRENT_DESKTOP=sway \
      ${pkgs.dbus}/bin/dbus-run-session -- ${pkgs.sway}/bin/sway

    # systemd-run returning only means the request was accepted. Confirm that
    # Sway survives initialization before reporting success to the SSH client.
    for attempt in $(${pkgs.coreutils}/bin/seq 1 30); do
      if ${pkgs.procps}/bin/pgrep -xu "$USER" -x sway >/dev/null; then
        echo "Sway started on $(hostname)."
        exit 0
      fi
      state="$(${pkgs.systemd}/bin/systemctl --user show sway-remote.service -p ActiveState --value 2>/dev/null || true)"
      if [ "$state" = failed ] || [ "$state" = inactive ]; then
        echo "Sway failed to start. Recent log:" >&2
        ${pkgs.systemd}/bin/journalctl --user -u sway-remote.service -n 40 --no-pager >&2
        exit 1
      fi
      ${pkgs.coreutils}/bin/sleep 0.2
    done

    echo "Sway launch timed out. Recent log:" >&2
    ${pkgs.systemd}/bin/journalctl --user -u sway-remote.service -n 40 --no-pager >&2
    exit 1
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
