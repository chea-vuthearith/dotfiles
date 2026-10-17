# Every .nix file under modules/ is a flake-parts module (loaded by import-tree in
# flake.nix). Features publish NixOS/home-manager modules under flake.modules.
{inputs, ...}: {
  imports = [inputs.flake-parts.flakeModules.modules];
  systems = ["x86_64-linux"];
}
