{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.packages = with pkgs; [
      redis
      sqlite
      postgresql
      sqlfluff
      prisma-language-server
    ];
  };
}
