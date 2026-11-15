{ config, lib, pkgs, ... }:
let
  swayVtSession = pkgs.writeShellScript "sway-vt-session" ''
    set -Eeuo pipefail
    uid="$(${pkgs.coreutils}/bin/id -u joel)"
    runtime="/run/user/$uid"

    exec /run/wrappers/bin/su \
      --login joel \
      --command "export XDG_RUNTIME_DIR='$runtime'; export DBUS_SESSION_BUS_ADDRESS='unix:path=$runtime/bus'; exec sway"
  '';

  swayRemote = pkgs.writeShellApplication {
    name = "sway-remote";
    runtimeInputs = [ pkgs.coreutils pkgs.kbd pkgs.procps ];
    text = ''
      export SWAY_VT_SESSION=${swayVtSession}
      ${builtins.readFile ./sway-remote-launcher.sh}
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
        { command = "/run/current-system/sw/bin/fgconsole"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/chvt"; options = [ "NOPASSWD" ]; }
        { command = "/home/joel/.config/sway/scripts/rotate-touchpad.py"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/reset-hyperx-dac"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];
}
