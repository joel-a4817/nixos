{ lib, pkgs, ... }:
let
  home = "/home/joel";
  scripts = "${home}/.config/sway/scripts/network";
  syncState = "${home}/minecraft-server";
  runtimeRoot = "/srv/minecraft";
  floatingAddress = "192.168.0.240";

  moddedMods = {
    fabric-api = pkgs.runCommand "fabric-api-0.165.0+26.3.jar" {} ''
      cp ${builtins.fetchurl "https://www.curseforge.com/api/v1/mods/306612/files/9295874/download"} "$out"
    '';
    lithium = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/xS0Q8LSi/lithium-fabric-0.26.2%2Bmc26.3.jar";
      sha512 = "4d7fee66132eedc71feab9390b92c95d7058edbdad0fecfac1d836a2950b97a7ca463afbede61c7ef361ce65e1f927ab9e89dde5bf2e0e0ce486afb5c5dbee40";
    };
    ferrite-core = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/uXXizFIs/versions/d5ddUdiB/ferritecore-9.0.0-fabric.jar";
      sha512 = "d81fa97e11784c19d42f89c2f433831d007603dd7193cee45fa177e4a6a9c52b384b198586e04a0f7f63cd996fed713322578bde9a8db57e1188854ae5cbe584";
    };
    lithostitched = pkgs.runCommand "lithostitched-2.0.6-fabric-26.3.jar" {} ''
      cp ${builtins.fetchurl "https://www.curseforge.com/api/v1/mods/936015/files/9154966/download"} "$out"
    '';
    terralith = pkgs.runCommand "Terralith_26.3_v2.6.5+26.3.jar" {} ''
      cp ${builtins.fetchurl "https://www.curseforge.com/api/v1/mods/513688/files/8994208/download"} "$out"
    '';
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
      version = "26_3";
      port = 25565;
      memory = "4G";
      motd = "monkeyterralith";
      maxPlayers = 12;
      viewDistance = 12;
      simulationDistance = 8;
      mods = moddedMods;
    }
    {
      name = "latest-server";
      version = "26_3";
      port = 25566;
      memory = "4G";
      motd = "latestmonkey";
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
      white-list = false;
      enforce-whitelist = false;
      max-players = server.maxPlayers;
      motd = server.motd;
      difficulty = "normal";
      gamemode = "survival";
      # Required by minecraft-server.py for save-off/save-all flush/save-on
      # while taking consistent online backups. Keep this declarative because
      # nix-minecraft regenerates server.properties during service startup.
      enable-rcon = true;
      "rcon.password" = "minecraft-backup-${server.name}-4817";
      "rcon.port" = server.port + 1000;
      broadcast-rcon-to-ops = false;
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
      # nix-minecraft generates pre-start, stop and post-stop helpers that all
      # inherit WorkingDirectory.  Create that directory before systemd tries
      # to chdir, and run the whole lifecycle under the same stable account.
      unitConfig.RequiresMountsFor = [ "${runtimeRoot}/${server.name}" ];
      serviceConfig = {
        User = lib.mkForce "joel";
        Group = lib.mkForce "users";
        UMask = "0007";
        WorkingDirectory = lib.mkForce "${runtimeRoot}/${server.name}";
        # These units are intentionally user-selected (autoStart=false).  Let
        # minecraft-server.py report the first real failure instead of hiding
        # it behind a rapid restart loop and start-limit-hit.
        Restart = lib.mkForce "no";
      };
    }) checked);

  environment.etc."minecraft-port-forwarding.txt".text = ''
    MINECRAFT PORT FORWARDING

    Floating LAN address: ${floatingAddress}

    Router rules (External host blank):
      TCP 25565 -> ${floatingAddress}:25565  modded-server
      TCP 25566 -> ${floatingAddress}:25566  latest-server

    Router DHCP:
      Exclude ${floatingAddress} from the DHCP allocation pool.
      Do not reserve it to either laptop MAC address.

    Peers files:
      On rt4817: lt4817 joel@lt4817
      On lt4817: rt4817 joel@rt4817

    Optional permanent friend hostname:
      Create ~/.config/minecraft-server/ddns.env (mode 600):
        DUCKDNS_DOMAIN=your-subdomain
        DUCKDNS_TOKEN=your-token
      Friends then use your-subdomain.duckdns.org:25565 or :25566.
  '';

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "minecraft-port-forwarding" ''
      cat /etc/minecraft-port-forwarding.txt
    '')
    rsync openssh curl jq networkmanager tmux iproute2 iputils
  ];

  systemd.tmpfiles.rules = [
    "d ${syncState} 0750 joel users -"
    "d ${runtimeRoot} 2770 joel users -"
    "Z ${runtimeRoot} 2770 joel users -"
    "d ${syncState}/servers 0750 joel users -"
    "d ${syncState}/backups 0750 joel users -"
    "d ${syncState}/coordination 0750 joel users -"
    "d ${scripts} 0755 joel users -"
  ] ++ lib.concatMap (server: [
    "d ${runtimeRoot}/${server.name} 2770 joel users -"
    "Z ${runtimeRoot}/${server.name} 2770 joel users -"
    "d ${syncState}/servers/${server.name}/snapshot 0750 joel users -"
  ]) checked;

  system.activationScripts.minecraftRuntimePermissions = lib.stringAfter [ "users" "groups" ] ''
    install -d -m 2770 -o joel -g users ${runtimeRoot}
    chown -R joel:users ${runtimeRoot}
    chmod -R u+rwX,g+rwX,o-rwx ${runtimeRoot}
    find ${runtimeRoot} -type d -exec chmod 2770 {} +
    find ${runtimeRoot} -type f -exec chmod 0660 {} +
  '';

  security.sudo.extraRules = [{
    users = [ "joel" ];
    commands = [
      { command = "/run/current-system/sw/bin/ip"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/arping"; options = [ "NOPASSWD" ]; }
    ] ++ lib.concatMap (server: [
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
      {
        command = "/run/current-system/sw/bin/systemctl reset-failed minecraft-server-${server.name}.service";
        options = [ "NOPASSWD" ];
      }
    ]) checked;
  }];
}
