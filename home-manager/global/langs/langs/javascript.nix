{pkgs, ...}: {
  home.packages = with pkgs; [
    nodejs_24
    pnpm_10
    turbo
    vtsls # just in case tsgo breaks
    bun
    typescript
    biome
    tailwindcss-language-server
  ];
}
