{
  description = "Drive a KDE Plasma Wayland desktop from a terminal agent";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAll (pkgs: rec {
        kde-wayland-agent-tools = pkgs.callPackage ./package.nix { };
        default = kde-wayland-agent-tools;
      });
      overlays.default = final: prev: {
        kde-wayland-agent-tools = final.callPackage ./package.nix { };
      };
    };
}
