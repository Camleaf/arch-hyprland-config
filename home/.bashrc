
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export QT_QPA_PLATFORMTHEME="qt6ct"
export QT_STYLE_OVERRIDE="breeze"
export QT_PLUGIN_PATH="$HOME/.local/lib/qt6/plugins"
export XDG_DATA_HOME="$HOME/.local/share"
export EDITOR="nvim"
export VISUAL="nvim"

# Aliases
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons=auto --group-directories-first'
else
    alias ls='ls --color=auto'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
fi

alias grep='grep --color=auto'

# FZF Integration
[[ -f ~/.fzf/shell/key-bindings.bash ]] && source ~/.fzf/shell/key-bindings.bash
[[ -f ~/.fzf/shell/completion.bash ]] && source ~/.fzf/shell/completion.bash

# Zoxide
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

# Starship Prompt
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"


# -- cam-cli
export PATH="$PATH:$HOME/bin"

eval "$(ssh-agent -s)"
