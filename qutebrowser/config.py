
import os
from urllib.request import urlopen

config.load_autoconfig(True)

# Theme
if not os.path.exists(config.configdir / "theme.py"):
    theme = "https://raw.githubusercontent.com/catppuccin/qutebrowser/main/setup.py"
    with urlopen(theme) as themehtml:
        with open(config.configdir / "theme.py", "a") as file:
            file.writelines(themehtml.read().decode("utf-8"))

if os.path.exists(config.configdir / "theme.py"):
    import theme
    theme.setup(c, 'mocha', True)

# Key Bindings
config.bind('<Escape>', 'mode-leave ;; jseval -q document.activeElement.blur()', mode='insert')

config.bind("<Ctrl-p>", "completion-item-focus prev", mode="command")
config.bind("<Ctrl-n>", "completion-item-focus next", mode="command")

config.bind("s", "hint")
config.bind("S", "hint all tab")

config.bind('<Alt-l>', 'tab-next' )
config.bind('<Alt-h>', 'tab-prev' )
config.bind("<Alt-Shift-L>", "tab-move +")
config.bind("<Alt-Shift-H>", "tab-move -")

config.bind('<Ctrl-i>', 'forward' )
config.bind('<Ctrl-o>', 'back' )

config.bind('<Alt-W><Tab>d', 'tab-close' )
config.bind('<Alt-W><Tab><Tab>', 'open -t' )

config.bind('dd', 'tab-close' )
config.bind('gh', 'history' )

# Unbind Defaults
config.unbind('d')
config.unbind('f')
config.unbind('F')
config.unbind('sf')
config.unbind('sk')
config.unbind('sl')
config.unbind('ss')


# Settings
c.auto_save.session = True
c.fonts.default_family = "System-ui"
c.content.autoplay = False
c.colors.webpage.preferred_color_scheme = "dark"
c.tabs.position = 'bottom'
c.statusbar.show = 'in-mode'
c.tabs.show = 'multiple'
c.tabs.last_close = 'close'
c.tabs.tooltips = False
c.window.hide_decoration = True
