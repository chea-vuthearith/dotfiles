{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    nixd
    alejandra
    statix
  ];

  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"]; # for nixd lsp
}
