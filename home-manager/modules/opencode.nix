{pkgs, ...}: {
  programs.opencode = {
    enable = true;
    settings = {
      plugin = ["@mohak34/opencode-notifier@latest"];
    };
  };
}
