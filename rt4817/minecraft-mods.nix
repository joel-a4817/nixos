{ pkgs }:
{
  # Add declarative Fabric mods here. Generate each fetchurl block with:
  # nix run github:Infinidoge/nix-minecraft#nix-modrinth-prefetch -- VERSION_ID
  #
  # Example shape:
  # lithium = pkgs.fetchurl {
  #   url = "https://cdn.modrinth.com/.../lithium.jar";
  #   hash = "sha512-...";
  # };
}
