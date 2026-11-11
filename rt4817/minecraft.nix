{ lib, pkgs, ... }:
let
  home = "/home/joel";
  scripts = "${home}/.config/sway/scripts/network";
  syncState = "${home}/minecraft-server";
  runtimeRoot = "${home}/.local/state/minecraft-server/runtime";
  serverMods = import ./minecraft-mods.nix { inherit pkgs; };
in {
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    dataDir = runtimeRoot;
    servers.main = {
      enable = true;
      autoStart = false;
      restart = "no";
      package = pkgs.fabricServers.fabric;
      jvmOpts = "-Xms1G -Xmx4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200";
      serverProperties = {
        server-port = 25565;
        server-ip = "";
        online-mode = true;
        white-list = true;
        enforce-whitelist = true;
        max-players = 12;
        motd = "Joel's Fabric Minecraft server";
        difficulty = "normal";
        gamemode = "survival";
        enable-rcon = false;
        enable-query = false;
        sync-chunk-writes = true;
        view-distance = 10;
        simulation-distance = 8;
      };
      symlinks.mods = pkgs.linkFarmFromDrvs "minecraft-fabric-mods" (builtins.attrValues serverMods);
    };
  };

  systemd.services.minecraft-server-main = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" "NetworkManager.service" ];
    serviceConfig = {
      User = lib.mkForce "joel";
      Group = lib.mkForce "users";
      TimeoutStopSec = lib.mkForce "180s";
    };
  };

  environment.systemPackages = with pkgs; [ rsync openssh curl jq networkmanager tmux ];

  systemd.tmpfiles.rules = [
    "d ${syncState} 0750 joel users -"
    "d ${home}/.local/state/minecraft-server 0750 joel users -"
    "d ${runtimeRoot} 0750 joel users -"
    "d ${syncState}/snapshot 0750 joel users -"
    "d ${syncState}/backups 0750 joel users -"
    "d ${syncState}/coordination 0750 joel users -"
    "d ${scripts} 0755 joel users -"
  ];

  security.sudo.extraRules = [{
    users = [ "joel" ];
    commands = [
      { command = "/run/current-system/sw/bin/systemctl start minecraft-server-main.service"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/systemctl stop minecraft-server-main.service"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/systemctl is-active minecraft-server-main.service"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/systemctl start syncthing.service"; options = [ "NOPASSWD" ]; }
    ];
  }];
}
