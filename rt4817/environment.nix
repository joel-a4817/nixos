{ config, lib, pkgs, ... }:
let
  swayOnVt = pkgs.writeShellScript "sway-on-vt" ''
    set -Eeuo pipefail

    uid="$(${pkgs.coreutils}/bin/id -u joel)"
    runtime="/run/user/$uid"

    exec ${pkgs.util-linux}/bin/runuser -u joel -- \
      ${pkgs.coreutils}/bin/env \
        HOME=/home/joel \
        USER=joel \
        LOGNAME=joel \
        SHELL=${pkgs.bashInteractive}/bin/bash \
        PATH=/home/joel/.nix-profile/bin:/etc/profiles/per-user/joel/bin:/run/wrappers/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin \
        XDG_RUNTIME_DIR="$runtime" \
        XDG_CONFIG_HOME=/home/joel/.config \
        XDG_DATA_HOME=/home/joel/.local/share \
        XDG_STATE_HOME=/home/joel/.local/state \
        XDG_CACHE_HOME=/home/joel/.cache \
        DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime/bus" \
        XDG_SESSION_TYPE=wayland \
        XDG_SESSION_DESKTOP=sway \
        XDG_CURRENT_DESKTOP=sway \
        LIBSEAT_BACKEND=seatd \
        ${pkgs.bashInteractive}/bin/bash --login -c '
          systemctl --user import-environment \
            DISPLAY WAYLAND_DISPLAY SWAYSOCK \
            XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP \
            PATH XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME 2>/dev/null || true
          dbus-update-activation-environment --systemd \
            DISPLAY WAYLAND_DISPLAY SWAYSOCK \
            XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP \
            PATH XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME 2>/dev/null || true
          exec /run/current-system/sw/bin/sway
        '
  '';

  swayRemote = pkgs.writeShellApplication {
    name = "sway-remote";
    runtimeInputs = [ pkgs.coreutils pkgs.kbd pkgs.procps ];
    text = ''
      export SWAY_ON_VT=${swayOnVt}
      ${builtins.readFile ./sway-remote.sh}
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
        { command = "/run/current-system/sw/bin/setsid"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/openvt"; options = [ "NOPASSWD" ]; }
        { command = "/home/joel/.config/sway/scripts/rotate-touchpad.py"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/reset-hyperx-dac"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];
}
