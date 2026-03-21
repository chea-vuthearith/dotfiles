{pkgs, ...}: {
  home.packages = with pkgs; [
    nodejs_24
    pnpm_10
    turbo
    vtsls # just in case tsgo breaks
    typescript-go
    biome
    tailwindcss-language-server
  ];
}
