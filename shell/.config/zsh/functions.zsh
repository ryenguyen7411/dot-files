# =============================================================================
# SHELL FUNCTIONS
# =============================================================================

# ---------------------------
# Git Utilities
# ---------------------------

# Reset to N commits back
reset() {
  git reset HEAD~"$1"
}

# Hard reset to N commits back
rhard() {
  gac
  git reset --hard HEAD~"$1"
}

# Cherry pick visualization
git-cherry() {
  git cherry -v $1 | tail -n 50 | awk '/^\+/ {print "\033[31m" $0 "\033[39m"} /^\-/ {print "\033[32m" $0 "\033[39m"}'
}

# ---------------------------
# Process Management
# ---------------------------

# Kill process by port
if command_exists lsof; then
  killp() {
    kill $(lsof -ti:$1)
  }
fi

# Kill process by name
killname() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "Usage: killname <process_name>"
    return 1
  fi
  pkill -f "$name" && echo "Killed processes matching: $name"
}

# ---------------------------
# Environment Management
# ---------------------------

# Environment switcher
senv() {
  case "$1" in
    which)
      if [[ -x "$HOME/env" ]]; then
        ~/env env
      else
        echo "Environment script not found at $HOME/env"
      fi
      ;;
    prod)
      if [[ -d "$HOME/notes/env/prod" ]]; then
        rm -rf ~/env && ln -s ~/notes/env/prod ~/env && echo "Switched to production environment"
      else
        echo "Production environment not found at $HOME/notes/env/prod"
      fi
      ;;
    dev|*)
      if [[ -d "$HOME/notes/env/dev" ]]; then
        rm -rf ~/env && ln -s ~/notes/env/dev ~/env && echo "Switched to development environment"
      else
        echo "Development environment not found at $HOME/notes/env/dev"
      fi
      ;;
  esac
}

# ---------------------------
# Development Workflow
# ---------------------------

# Create and enter directory
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      7z x "$1" ;;
      *)         echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# ---------------------------
# Cloud & Infrastructure
# ---------------------------

# Lazy load helper
lazy_load() {
  local func_name="$1"
  local loader_func="$2"

  eval "$func_name() {
    unset -f $func_name
    $loader_func
    $func_name \"\$@\"
  }"
}

# GCloud/Kubernetes environment switcher (lazy loaded)
_load_swe() {
  swe() {
    case $1 in
      develop)
        gcloud config set project gam-project-cgd-x0l-zm4
        gcloud container clusters get-credentials bu1-k8s-dev --zone=asia-southeast1-a
        ;;
      stage)
        gcloud config set project veep-staging
        gcloud container clusters get-credentials default --zone=asia-southeast1-a
        ;;
      production)
        gcloud config set project veep-production
        gcloud container clusters get-credentials default --zone=asia-southeast1-a
        ;;
      saas)
        gcloud config set project veep-production
        gcloud container clusters get-credentials saas-1 --region=asia-southeast1
        ;;
      qa)
        gcloud config set project veep-staging
        gcloud container clusters get-credentials qa --zone=asia-southeast1-a
        ;;
      cake-dev)
        gcloud config set project bef-cake-sandbox
        gcloud container clusters get-credentials cake-dev-2 --zone=asia-southeast1
        ;;
      cake-qa)
        gcloud config set project bef-cake-sandbox
        gcloud container clusters get-credentials cake-qa-1 --zone=asia-southeast1
        ;;
      cake-stage)
        gcloud config set project bef-cake-sandbox
        gcloud container clusters get-credentials cake-stage-1 --zone=asia-southeast1
        ;;
      cake-prod)
        gcloud config set project bef-cake-prod
        gcloud container clusters get-credentials cake-prod-1 --zone=asia-southeast1
        ;;
      help|*)
        echo "Available environments:"
        echo "  develop    - Development environment"
        echo "  stage      - Staging environment"
        echo "  production - Production environment"
        echo "  qa         - QA environment"
        echo "  saas       - SaaS environment"
        echo "  cake-dev   - Cake development"
        echo "  cake-qa    - Cake QA"
        echo "  cake-stage - Cake staging"
        echo "  cake-prod  - Cake production"
        ;;
    esac
  }
}

lazy_load swe _load_swe

# ---------------------------
# External Sources
# ---------------------------

# Tool completions
safe_source "$HOME/.bun/_bun"
safe_source "$HOME/google-cloud-sdk/path.zsh.inc"
safe_source "$HOME/google-cloud-sdk/completion.zsh.inc"
safe_source "$HOME/.local/bin/env"

# ---------------------------
# Utility & Maintenance
# ---------------------------

# Edit zshrc
zshrc-edit() {
  ${EDITOR:-vim} ~/.zshrc && echo "Reload with: zshr"
}

# Reload zshrc
zshrc-reload() {
  source ~/.zshrc && echo "Configuration reloaded"
}

# Backup zshrc
zshrc-backup() {
  local backup_file="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
  cp ~/.zshrc "$backup_file" && echo "Backup created: $backup_file"
}

# Profile load time
zshrc-profile() {
  local start_time=$(date +%s.%3N)
  source ~/.zshrc >/dev/null 2>&1
  local end_time=$(date +%s.%3N)
  local load_time=$(echo "$end_time - $start_time" | bc)
  echo "ZSH configuration loaded in ${load_time}s"
}

# Debug mode
zshrc-debug-on() {
  export ZSH_DEBUG=1
  echo "Debug mode enabled. Reload config to see debug output."
}

zshrc-debug-off() {
  unset ZSH_DEBUG
  echo "Debug mode disabled."
}

# Plugin status
zshrc-plugins() {
  echo "Loaded ZSH plugins:"
  for plugin in "${plugins[@]}"; do
    if [[ -d "$ZSH/custom/plugins/$plugin" ]]; then
      echo "  - $plugin (custom)"
    elif [[ -d "$ZSH/plugins/$plugin" ]]; then
      echo "  - $plugin (built-in)"
    else
      echo "  - $plugin (command-based)"
    fi
  done
}

# Path diagnostics
zshrc-path() {
  echo "PATH contents (one per line):"
  echo "$PATH" | tr ':' '\n' | nl
}

# Environment summary
zshrc-info() {
  echo "=== ZSH Configuration Info ==="
  echo "Version: 4.0.0"
  echo "ZSH Version: $ZSH_VERSION"
  echo "Theme: $ZSH_THEME"
  echo "Plugins: ${#plugins[@]} loaded"
  echo "PATH entries: $(echo "$PATH" | tr ':' '\n' | wc -l)"
  echo "Terminal: $TERM"
  echo "Editor: ${EDITOR:-not set}"
  echo "Debug mode: ${ZSH_DEBUG:-disabled}"
}

