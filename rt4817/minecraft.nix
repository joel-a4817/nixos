{ config, lib, pkgs, ... }:
let
  home = "/home/joel";
  scripts = "${home}/.config/sway/scripts";
  state = "${home}/minecraft-server";
  runtime = "${home}/.local/state/minecraft-server/runtime";
in {
  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;
    declarative = true;
    dataDir = runtime;
    jvmOpts = "-Xms1G -Xmx4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200";
    serverProperties = {
      server-port = 25565;
      online-mode = true;
      white-list = true;
      enforce-whitelist = true;
      max-players = 12;
      motd = "Joel's Minecraft server";
      difficulty = "normal";
      gamemode = "survival";
      enable-rcon = false;
      enable-query = false;
      sync-chunk-writes = true;
      view-distance = 10;
      simulation-distance = 8;
    };
  };

  # Manual only. The management command starts/stops it transactionally.
  systemd.services.minecraft-server = {
    wantedBy = lib.mkForce [ ];
    serviceConfig = {
      Restart = lib.mkForce "no";
      User = lib.mkForce "joel";
      Group = lib.mkForce "users";
      WorkingDirectory = lib.mkForce runtime;
      TimeoutStopSec = "180s";
      KillSignal = "SIGINT";
      SuccessExitStatus = [ "0" "143" ];
    };
  };

  environment.systemPackages = with pkgs; [
    minecraft-server
    rsync
    openssh
    curl
    jq
  ];

  # Install stable entry points while keeping the editable source in ~/nixos.
  environment.etc."minecraft-server/minecraft-server.py" = {
    source = ./minecraft-server.py;
    mode = "0755";
  };
  environment.etc."minecraft-server/start-services.sh" = {
    source = ./start-services.sh;
    mode = "0755";
  };
  environment.etc."minecraft-server/start-ipad-webremote.sh" = {
    source = ./start-ipad-webremote.sh;
    mode = "0755";
  };

  systemd.tmpfiles.rules = [
    "d ${state} 0750 joel users -"
    "d ${home}/.local/state/minecraft-server 0750 joel users -"
    "d ${runtime} 0750 joel users -"
    "d ${state}/snapshot 0750 joel users -"
    "d ${state}/backups 0750 joel users -"
    "d ${state}/coordination 0750 joel users -"
    "d ${scripts} 0755 joel users -"
    "L+ ${scripts}/minecraft-server.py - - - - /etc/minecraft-server/minecraft-server.py"
    "L+ ${scripts}/start-services.sh - - - - /etc/minecraft-server/start-services.sh"
    "L+ ${scripts}/start-ipad-webremote.sh - - - - /etc/minecraft-server/start-ipad-webremote.sh"
  ];

  security.sudo.extraRules = [{
    users = [ "joel" ];
    commands = [
      { command = "/run/current-system/sw/bin/systemctl start minecraft-server.service"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/systemctl stop minecraft-server.service"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/systemctl is-active minecraft-server.service"; options = [ "NOPASSWD" ]; }
    ];
  }];
}
