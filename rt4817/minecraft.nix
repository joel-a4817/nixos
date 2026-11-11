{ lib, pkgs, ... }:
let
  home = "/home/joel";
  scripts = "${home}/.config/sway/scripts/network";
  syncState = "${home}/minecraft-server";
  runtimeRoot = "${home}/.local/state/minecraft-server/runtime";
  definitions = import ./minecraft-servers.nix { inherit pkgs; };

  validName = name: builtins.match "[a-z0-9][a-z0-9-]*" name != null;
  checked = map (server:
    assert lib.assertMsg (validName server.name)
      "Minecraft server name '${server.name}' must contain only lowercase letters, digits and hyphens";
    assert lib.assertMsg (server.port >= 1 && server.port <= 65535)
      "Minecraft server '${server.name}' has an invalid TCP port";
    assert lib.assertMsg (builtins.hasAttr "fabric-${server.version}" pkgs.fabricServers)
      "No nix-minecraft Fabric package for version '${server.version}' (expected pkgs.fabricServers.fabric-${server.version})";
    server
  ) definitions;

  names = map (server: server.name) checked;
  ports = map (server: server.port) checked;
  noDuplicates = values: builtins.length values == builtins.length (lib.unique values);

  mkServer = server: {
    name = server.name;
    value = {
      enable = true;
      autoStart = false;
      restart = "no";
      package = builtins.getAttr "fabric-${server.version}" pkgs.fabricServers;
      jvmOpts = "-Xms1G -Xmx${server.memory} -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200";
      serverProperties = {
        server-port = server.port;
        server-ip = "";
        online-mode = true;
        white-list = true;
        enforce-whitelist = true;
        max-players = server.maxPlayers;
        motd = server.motd;
        difficulty = "normal";
        gamemode = "survival";
        enable-rcon = false;
        enable-query = false;
        sync-chunk-writes = true;
        view-distance = 10;
        simulation-distance = 8;
      };
      symlinks.mods = pkgs.linkFarmFromDrvs
        "minecraft-${server.name}-fabric-mods"
        (builtins.attrValues server.mods);
    };
  };
in
assert lib.assertMsg (checked != [ ]) "minecraft-servers.nix must define at least one server";
assert lib.assertMsg (noDuplicates names) "Minecraft server names must be unique";
assert lib.assertMsg (noDuplicates ports) "Minecraft server ports must be unique";
{
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    dataDir = runtimeRoot;
    servers = builtins.listToAttrs (map mkServer checked);
  };

  systemd.services = builtins.listToAttrs (map (server: {
    name = "minecraft-server-${server.name}";
    value = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" "NetworkManager.service" ];
      serviceConfig = {
        User = lib.mkForce "joel";
        Group = lib.mkForce "users";
        ProtectHome = lib.mkForce false;
        ReadWritePaths = lib.mkForce [ runtimeRoot ];
        TimeoutStopSec = lib.mkForce "180s";
      };
    };
  }) checked);

  environment.systemPackages = with pkgs; [ rsync openssh curl jq networkmanager tmux ];

  systemd.tmpfiles.rules = [
    "d ${syncState} 0750 joel users -"
    "d ${home}/.local/state/minecraft-server 0750 joel users -"
    "d ${runtimeRoot} 0750 joel users -"
    "d ${syncState}/servers 0750 joel users -"
    "d ${syncState}/backups 0750 joel users -"
    "d ${syncState}/coordination 0750 joel users -"
    "d ${scripts} 0755 joel users -"
  ] ++ map (server: "d ${syncState}/servers/${server.name}/snapshot 0750 joel users -") checked;

  security.sudo.extraRules = [{
    users = [ "joel" ];
    commands = lib.concatMap (server: [
      { command = "/run/current-system/sw/bin/systemctl start minecraft-server-${server.name}.service"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/systemctl stop minecraft-server-${server.name}.service"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/systemctl is-active minecraft-server-${server.name}.service"; options = [ "NOPASSWD" ]; }
    ]) checked;
  }];
}
