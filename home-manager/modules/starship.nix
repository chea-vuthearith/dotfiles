{...}: {
  programs.starship = {
    enable = true;
    enableTransience = true;
    enableZshIntegration = true;
    settings = {
      git_status = {
        stashed = "\\$${count}";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕\${count}";
        conflicted = "=\${count}";
        deleted = "✘\${count}";
        renamed = "»\${count}";
        modified = "!\${count}";
        staged = "+\${count}";
        untracked = "?\${count}";
      };
    };
  };
}
