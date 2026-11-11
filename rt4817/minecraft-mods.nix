{ pkgs, ... }:
{
  # Add declarative Fabric mods here. Generate each fetchurl block with:
  # nix run github:Infinidoge/nix-minecraft#nix-modrinth-prefetch -- VERSION_ID
  #
  # example = pkgs.fetchurl {
  #   url = "https://cdn.modrinth.com/.../mod.jar";
  #   hash = "sha512-...";
  # };
}
