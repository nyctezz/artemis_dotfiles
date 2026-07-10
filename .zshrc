# ==========================
# History
# ==========================
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# ==========================
# Shell Options
# ==========================
setopt autocd
setopt extendedglob
setopt nomatch
setopt notify
unsetopt beep

# Use vi keybindings
bindkey -v

# ==========================
# Completion System
# ==========================
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit

# Case-insensitive and substring matching
zstyle ':completion:*' matcher-list \
    'm:{a-z}={A-Za-z}' \
    'r:|=*' \
    'l:|=*'

# Interactive completion menu
zstyle ':completion:*' menu yes select

# Nice formatting for completion lists
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Use fd for fast directory previews in cd completion
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'fd --type d . $realpath'

# ==========================
# Plugins
# ==========================

# Autosuggestions (history)
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# fzf
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# fzf-tab (installed from AUR)
source /usr/share/fzf-tab/fzf-tab.plugin.zsh

# Syntax highlighting (must be last)
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ==========================
# Prompt
# ==========================
eval "$(starship init zsh)"

# ==========================
# Aliases
# ==========================
alias sudo='sudo '
alias start-gopro="$HOME/gopro-stream.sh"
