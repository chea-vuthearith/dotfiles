{...}: {
  programs.vscode = {
    enable = true;
    profiles.default = {
      userSettings = {
        workbench.editor.showTabs = "none";
        keyboard.dispatch = "keyCode";
        editor = {
          cursorSmoothCaretAnimation = "on";
          lineNumbers = "relative";
          cursorBlinking = "phase";
        };
        extensions.experimental.affinity.asvetliakov.vscode-neovim = 1;
        editor.minimap.enabled = false;
        explorer.confirmDragAndDrop = false;
        github.copilot.nextEditSuggestions.enabled = true;
      };
      keybindings = [
        {
          key = "space e";
          command = "runCommands";
          args = {
            commands = [
              "workbench.action.toggleSidebarVisibility"
              "workbench.action.focusActiveEditorGroup"
            ];
          };
          when = "explorerViewletFocus";
        }
        {
          key = "ctrl+/";
          command = "workbench.action.terminal.toggleTerminal";
          when = "terminal.active";
        }
        {
          key = "ctrl+`";
          command = "-workbench.action.terminal.toggleTerminal";
          when = "terminal.active";
        }
        {
          key = "ctrl+p";
          command = "-workbench.action.quickOpenNavigateNextInFilePicker";
          when = "inFilesPicker && inQuickOpen";
        }
        {
          key = "ctrl+p";
          command = "-workbench.action.quickOpen";
        }
      ];
    };
  };
}
