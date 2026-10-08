# === SDKMAN & RBENV PATHS (Directly on PATH for 0ms startup) ===
export SDKMAN_DIR="$HOME/.sdkman"
export PATH="$SDKMAN_DIR/candidates/java/current/bin:$SDKMAN_DIR/candidates/gradle/current/bin:$SDKMAN_DIR/candidates/kotlin/current/bin:$SDKMAN_DIR/candidates/maven/current/bin:$HOME/.rbenv/shims:$PATH"

# === BASIC PATHS ===
export PATH="/opt/homebrew/bin:/opt/homebrew/opt/sqlite/bin:$HOME/bin:$HOME/.local/bin:$HOME/Library/Python/3.9/bin:$PATH"

# Antigravity IDE
export PATH="$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
# === DOCKER & TESTCONTAINERS (Colima on-demand) ===
export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE="/var/run/docker.sock"
# === WORK SECRETS & LOCAL CONFIGS (Ignored in Git) ===
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# === LANGUAGE & PACKAGE MANAGERS (Lazy-loaded for 0ms shell launch) ===
# PNPM
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# NVM (Node)
export NVM_DIR="$HOME/.config/nvm"
load_nvm() {
  unset -f nvm node npm yarn
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}
nvm() { load_nvm; nvm "$@"; }
node() { load_nvm; node "$@"; }
npm() { load_nvm; npm "$@"; }
yarn() { load_nvm; yarn "$@"; }

# SDKMAN (Java)
sdk() {
  unset -f sdk
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
  sdk "$@"
}

# rbenv (Ruby)
rbenv() {
  unset -f rbenv
  eval "$(command rbenv init - zsh)"
  rbenv "$@"
}

# Deno
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

# === FAST COMPLETIONS CACHE (0ms startup) ===
autoload -Uz compinit
if [[ ! -f ${ZDOTDIR:-$HOME}/.zcompdump ]]; then
  compinit
  zcompile "${ZDOTDIR:-$HOME}/.zcompdump" 2>/dev/null
else
  compinit -C
  [[ ! -s ${ZDOTDIR:-$HOME}/.zcompdump.zwc || ${ZDOTDIR:-$HOME}/.zcompdump -nt ${ZDOTDIR:-$HOME}/.zcompdump.zwc ]] && zcompile "${ZDOTDIR:-$HOME}/.zcompdump" 2>/dev/null
fi

# === ANTIDOTE PLUGIN MANAGER (zsh-vi-mode) ===
export ZVM_SYSTEM_CLIPBOARD_ENABLED=true
if [[ ! -s ~/.zsh_plugins.zsh || ~/.zsh_plugins.txt -nt ~/.zsh_plugins.zsh ]]; then
  [[ -f /opt/homebrew/opt/antidote/share/antidote/antidote.zsh ]] && source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh && antidote bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.zsh
fi
[[ -s ~/.zsh_plugins.zsh ]] && source ~/.zsh_plugins.zsh

# === CLI TOOLS & PRODUCTIVITY ===
# FZF (Fuzzy history search: Ctrl+R)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zoxide (Smarter cd)
if command -v zoxide >/dev/null 2>&1; then
  [[ ! -s ~/.zoxide.zsh ]] && zoxide init zsh > ~/.zoxide.zsh 2>/dev/null
  source ~/.zoxide.zsh
fi
zn() {
  z "$@" && nvim .
}

# Tmux Project Switcher (tmux-sessionizer)
alias tms="$HOME/.local/bin/tmux-sessionizer"
run_tmux_sessionizer() {
  BUFFER="tms"
  zle accept-line
}
zle -N run_tmux_sessionizer
bindkey '^f' run_tmux_sessionizer

function zvm_after_init() {
  zvm_bindkey viins '^f' run_tmux_sessionizer
  zvm_bindkey vicmd '^f' run_tmux_sessionizer
}

# === PURE NATIVE ZSH PROMPT (0.00ms overhead) ===
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes false
zstyle ':vcs_info:git:*' formats ' %F{blue}|%f %F{magenta}%b%f'
zstyle ':vcs_info:git:*' actionformats ' %F{blue}|%f %F{magenta}%b%f [%F{red}%a%f]'
precmd() { vcs_info }
setopt PROMPT_SUBST
PROMPT='%F{cyan}%1~%f${vcs_info_msg_0_}
%F{yellow}❯%f '

# === ALIASES & MODERN CLI REPLACEMENTS ===
# Gradle wrapper shorthand (finds gradlew in current or parent directory)
gw() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -x "$dir/gradlew" ]]; then
      "$dir/gradlew" "$@"
      return $?
    fi
    dir="$(dirname "$dir")"
  done
  command gradle "$@"
}

# Terminal Toys Menu
toys() {
  cat << 'EOF' | lolcat -F 0.3
  ████████╗ ██████╗ ██╗   ██╗███████╗
  ╚══██╔══╝██╔═══██╗╚██╗ ██╔╝██╔════╝
     ██║   ██║   ██║ ╚████╔╝ ███████╗
     ██║   ██║   ██║  ╚██╔╝  ╚════██║
     ██║   ╚██████╔╝   ██║   ███████║
     ╚═╝    ╚═════╝    ╚═╝   ╚══════╝
EOF
  echo ""
  echo -e "  \033[1;36msl\033[0m                      \033[90m|\033[0m  \033[38;5;250mSteam locomotive across your screen\033[0m"
  echo -e "  \033[1;36masciiquarium\033[0m            \033[90m|\033[0m  \033[38;5;250mUnderwater animated aquarium \033[90m(press 'q' to quit)\033[0m"
  echo -e "  \033[1;36mfortune\033[0m                 \033[90m|\033[0m  \033[38;5;250mRandom witty quotes and proverbs\033[0m"
  echo -e "  \033[1;36mfiglet \033[0;32m\"hi\"\033[0m             \033[90m|\033[0m  \033[38;5;250mGiant ASCII banner text\033[0m"
  echo -e "  \033[90m<cmd>\033[0m \033[1;33m|\033[0m \033[1;35mlolcat\033[0m          \033[90m|\033[0m  \033[38;5;250mPipe any command to colorize in rainbows \033[90m(e.g. fortune | lolcat)\033[0m"
  echo ""
}

alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias claude='~/.claude/launcher.sh'

# eza (Modern ls with icons)
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons=auto --group-directories-first"
  alias ll="eza -la --icons=auto --group-directories-first --git"
  alias lt="eza --tree --level=2 --icons=auto"
fi

# bat (Modern cat with syntax highlighting)
if command -v bat >/dev/null 2>&1; then
  alias cat="bat --paging=never --style=plain"
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/ryner/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)


# Added by Antigravity CLI installer
export PATH="/Users/ryner/.local/bin:$PATH"
alias agy="agy --dangerously-skip-permissions"
