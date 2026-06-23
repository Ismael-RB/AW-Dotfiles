source /usr/share/cachyos-fish-config/cachyos-config.fish

function fish_greeting; end

export PATH="$HOME/.local/bin:$PATH"

# Starship prompt
starship init fish | source

# Zoxide (smarter cd)
zoxide init fish | source
set -x PATH $HOME/desarrollo/flutter/bin $PATH
set -x PATH /opt/android-sdk/cmdline-tools/latest/bin /opt/android-sdk/platform-tools $PATH
