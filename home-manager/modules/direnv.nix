{inputs, ...}: {
  imports = [
    inputs.direnv-instant.homeModules.direnv-instant
  ];
  programs = {
    direnv-instant = {
      enable = true;
      enableZshIntegration = true;
    };
    direnv = {
      enable = true;
      enableZshIntegration = false; # use instant direnv
      silent = true;
    };
  };
}
