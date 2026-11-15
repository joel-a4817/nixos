{ config, lib, pkgs, ... }:

let
  swayRemote = pkgs.writeShellApplication {
    name = "sway-remote";

    runtimeInputs = with pkgs; [
      coreutils
      procps
      kbd
    ];

    text = ''
      set -Eeuo pipefail

      uid="$(id -u)"
      runtime="/run/user/$uid"

      if pid="$(pgrep -xo -u "$uid" sway 2>/dev/null)"; then
        tty="$(ps -o tty= -p "$pid" | xargs)"

        if [[ "$tty" =~ ^tty([0-9]+)$ ]]; then
          exec sudo chvt "''${BASH_REMATCH[1]}"
        fi

        printf 'Sway is already running as PID %s, but its VT is not detectable (%s).\n' \
          "$pid" "''${tty:-none}" >&2
        exit 1
      fi

      [[ -d "$runtime" ]] || {
        printf 'Missing runtime directory: %s\n' "$runtime" >&2
        exit 1
      }

      [[ -O "$runtime" ]] || {
        printf '%s is not owned by uid %s\n' "$runtime" "$uid" >&2
        exit 1
      }

      sudo openvt \
        --switch \
        --force \
        -- \
        /run/wrappers/bin/sudo \
        --user=joel \
        /run/current-system/sw/bin/env \
        HOME=/home/joel \
        USER=joel \
        LOGNAME=joel \
        XDG_RUNTIME_DIR="$runtime" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime/bus" \
        XDG_SESSION_TYPE=wayland \
        XDG_CURRENT_DESKTOP=sway \
        XDG_SESSION_DESKTOP=sway \
        /run/current-system/sw/bin/sway

      printf 'Sway launch triggered on a local VT.\n'
    '';
  };
in
{
  environment.systemPackages = [ swayRemote ];

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
    s = "sway-remote";
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

  security.sudo.extraRules = [
    {
      users = [ "joel" ];
      commands = [
        { command = "/run/current-system/sw/bin/timedatectl"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/pkill"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/openvt"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/chvt"; options = [ "NOPASSWD" ]; }
        { command = "/home/joel/.config/sway/scripts/rotate-touchpad.py"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/reset-hyperx-dac"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];
}
