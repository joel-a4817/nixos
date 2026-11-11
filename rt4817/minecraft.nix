{ lib, pkgs, ... }:
let
  home = "/home/joel";
  scripts = "${home}/.config/sway/scripts/network";
  syncState = "${home}/minecraft-server";
  runtimeRoot = "/srv/minecraft";

  moddedMods = {
    lithium = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/2mbrKlX3/lithium-fabric-0.14.0-snapshot%2Bmc1.21.1-build.88.jar";
      sha512 = "e7ff451152caa994521736b3144e7b3edc98ffee0e04bb8ce4381eb777d64fac2d4e9edf6928303c2228c02c5d09147d369e71c12b45c39b324daf6916e6d0a1";
    };
    ferrite-core = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/uXXizFIs/versions/bwKMSBhn/ferritecore-7.0.2-hotfix-fabric.jar";
      sha512 = "ca975bd3708cd96d30cf1447ac8883572113562eb2dd697e60c1cf382d6b70d0b1a511fcbfd042c51b2cf5d5ffc718b847f845e4c8a3e421e8c9ee741119a421";
    };
    terralith = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/8oi3bsk5/versions/MuJMtPGQ/Terralith_1.21.x_v2.5.8.jar";
      sha512 = "f862ed5435ce4c11a97d2ea5c40eee9f817c908f3223b5fd3e3fff0562a55111d7429dc73a2f1ca0b1af7b1ff6fa0470ed6efebb5de13336c40bb70fb357dd60";
    };
  };

  latestMods = {
    lithium = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/xS0Q8LSi/lithium-fabric-0.26.2%2Bmc26.3.jar";
      sha512 = "4d7fee66132eedc71feab9390b92c95d7058edbdad0fecfac1d836a2950b97a7ca463afbede61c7ef361ce65e1f927ab9e89dde5bf2e0e0ce486afb5c5dbee40";
    };
    ferrite-core = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/uXXizFIs/versions/d5ddUdiB/ferritecore-9.0.0-fabric.jar";
      sha512 = "d81fa97e11784c19d42f89c2f433831d007603dd7193cee45fa177e4a6a9c52b384b198586e04a0f7f63cd996fed713322578bde9a8db57e1188854ae5cbe584";
    };
  };

  definitions = [
    {
      name = "modded-server";
      version = "1_21_1";
      port = 25565;
      memory = "6G";
      motd = "Joel's Modded Server - Terralith";
      maxPlayers = 12;
      viewDistance = 10;
      simulationDistance = 8;
      mods = moddedMods;
    }
    {
      name = "latest-server";
      version = "26_3";
      port = 25566;
      memory = "4G";
      motd = "Joel's Latest Minecraft 26.3 Server";
      maxPlayers = 12;
      viewDistance = 12;
      simulationDistance = 8;
      mods = latestMods;
    }
  ];

  validName = name: builtins.match "[a-z0-9][a-z0-9-]*" name != null;
  names = map (server: server.name) definitions;
  ports = map (server: server.port) definitions;
  noDuplicates = values:
    builtins.length values == builtins.length (lib.unique values);

  checked = map (server:
    assert lib.assertMsg (validName server.name)
      "Minecraft server name '${server.name}' must use only lowercase letters, digits and hyphens";
    assert lib.assertMsg (server.port >= 1 && server.port <= 65535)
      "Minecraft server '${server.name}' has invalid port ${toString server.port}";
    server
  ) definitions;

  mkServer = server: lib.nameValuePair server.name {
    enable = true;
    autoStart = false;
    package =
      (pkgs.fabricServers.${"fabric-${server.version}"}).override {
        jre_headless = if server.version == "26_3"
          then pkgs.jdk25_headless
          else pkgs.jdk21_headless;
      };
    jvmOpts = lib.concatStringsSep " " [
      "-Xms1G"
      "-Xmx${server.memory}"
      "-XX:+UseG1GC"
      "-XX:+ParallelRefProcEnabled"
      "-XX:MaxGCPauseMillis=200"
    ];
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
      view-distance = server.viewDistance;
      simulation-distance = server.simulationDistance;
    };
    symlinks.mods = pkgs.linkFarmFromDrvs
      "minecraft-${server.name}-fabric-mods"
      (builtins.attrValues server.mods);
  };

in
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

  systemd.services = builtins.listToAttrs (map (server:
    lib.nameValuePair "minecraft-server-${server.name}" {
      serviceConfig = {
        User = lib.mkForce "joel";
        Group = lib.mkForce "users";
        UMask = "0007";
      };
    }) checked);

  environment.systemPackages = with pkgs; [
    rsync openssh curl jq networkmanager tmux
  ];

  systemd.tmpfiles.rules = [
    "d ${syncState} 0750 joel users -"
    "d ${runtimeRoot} 2770 joel users -"
    "Z ${runtimeRoot} 2770 joel users -"
    "d ${syncState}/servers 0750 joel users -"
    "d ${syncState}/backups 0750 joel users -"
    "d ${syncState}/coordination 0750 joel users -"
    "d ${scripts} 0755 joel users -"
  ] ++ map
    (server: "d ${syncState}/servers/${server.name}/snapshot 0750 joel users -")
    checked;

  security.sudo.extraRules = [{
    users = [ "joel" ];
    commands = lib.concatMap (server: [
      {
        command = "/run/current-system/sw/bin/systemctl start minecraft-server-${server.name}.service";
        options = [ "NOPASSWD" ];
      }
      {
        command = "/run/current-system/sw/bin/systemctl stop minecraft-server-${server.name}.service";
        options = [ "NOPASSWD" ];
      }
      {
        command = "/run/current-system/sw/bin/systemctl is-active minecraft-server-${server.name}.service";
        options = [ "NOPASSWD" ];
      }
    ]) checked;
  }];
}
