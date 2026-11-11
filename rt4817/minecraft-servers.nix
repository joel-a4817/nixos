{ pkgs }:
[
  {
    name = "main";
    version = "1_21_10";
    port = 25565;
    memory = "4G";
    motd = "Joel's Fabric Minecraft server";
    maxPlayers = 12;

    # Add fixed-output Fabric mod JARs here. Each server has its own set.
    # Generate a block with:
    # nix run github:Infinidoge/nix-minecraft#nix-modrinth-prefetch -- VERSION_ID
    mods = {
      # fabric-api = pkgs.fetchurl {
      #   url = "https://cdn.modrinth.com/.../fabric-api.jar";
      #   hash = "sha512-...";
      # };
    };
  }

  # Copy this block to add another independent server.
  # {
  #   name = "creative";
  #   version = "1_21_10";
  #   port = 25566;
  #   memory = "4G";
  #   motd = "Joel's creative server";
  #   maxPlayers = 8;
  #   mods = { };
  # }
]
