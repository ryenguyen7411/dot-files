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

# Open merge/pull request creation page for current branch
# Usage: gmr [source_branch] [target_branch]
#   gmr              → current branch → repo default target
#   gmr main         → current branch → main
#   gmr main staging → main → staging
gmr() {
  local remote_url base_url mr_url source_branch target_branch

  remote_url=$(git remote get-url origin 2>/dev/null)
  if [[ -z "$remote_url" ]]; then
    echo "Error: Not a git repository or no origin remote" >&2
    return 1
  fi

  case $# in
    0)
      source_branch=$(git branch --show-current)
      target_branch=""
      ;;
    1)
      source_branch=$(git branch --show-current)
      target_branch="$1"
      ;;
    *)
      source_branch="$1"
      target_branch="$2"
      ;;
  esac

  if [[ -z "$source_branch" ]]; then
    echo "Error: Not on a branch (detached HEAD?)" >&2
    return 1
  fi

  # Convert SSH to HTTPS format
  if [[ "$remote_url" =~ ^git@ ]]; then
    base_url=$(echo "$remote_url" | sed -E 's|^git@([^:]+):(.+)$|https://\1/\2|')
  else
    base_url="$remote_url"
  fi
  base_url="${base_url%.git}"

  local encoded_source=$(printf '%s' "$source_branch" | sed 's|/|%2F|g')
  local encoded_target=$(printf '%s' "$target_branch" | sed 's|/|%2F|g')

  case "$base_url" in
    *github.com*)
      if [[ -n "$target_branch" ]]; then
        mr_url="${base_url}/compare/${encoded_target}...${encoded_source}?expand=1"
      else
        mr_url="${base_url}/compare/${encoded_source}?expand=1"
      fi
      ;;
    *bitbucket*)
      mr_url="${base_url}/pull-requests/new?source=${encoded_source}"
      [[ -n "$target_branch" ]] && mr_url+="&dest=${encoded_target}"
      ;;
    *)
      mr_url="${base_url}/-/merge_requests/new?merge_request%5Bsource_branch%5D=${encoded_source}"
      [[ -n "$target_branch" ]] && mr_url+="&merge_request%5Btarget_branch%5D=${encoded_target}"
      ;;
  esac

  echo "Opening: $mr_url"
  open "$mr_url"
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
# Kubernetes (k3s via SSH tunnel)
# ---------------------------

# Wrapper for kubectl that ensures SSH tunnel to k3s is active
kubectl() {
  local tunnel_host="rye-opc"
  local local_port=6443
  local remote_port=6443

  # Check if tunnel already exists
  if ! pgrep -f "ssh.*-L.*${local_port}:127.0.0.1:${remote_port}.*${tunnel_host}" > /dev/null 2>&1; then
    echo "Starting SSH tunnel to k3s..." >&2
    ssh -f -N -L ${local_port}:127.0.0.1:${remote_port} ${tunnel_host}
    sleep 1  # Give tunnel time to establish
  fi

  # Run the actual kubectl command
  command kubectl "$@"
}

# Mount a Kubernetes pod's filesystem locally via sshfs
# Usage: kmount <pod_name> [local_path] [-n namespace] [-c container]
kmount() {
  local pod="" mount_path="" namespace="staging" container=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--namespace) namespace="$2"; shift 2 ;;
      -c|--container) container="$2"; shift 2 ;;
      *)
        if [[ -z "$pod" ]]; then
          pod="$1"
        elif [[ -z "$mount_path" ]]; then
          mount_path="$1"
        fi
        shift ;;
    esac
  done

  if [[ -z "$pod" ]]; then
    echo "Usage: kmount <pod_name> [local_path] [-n namespace] [-c container]"
    echo "  pod_name   : full or partial pod name (will grep for match)"
    echo "  local_path : mount point (default: ~/mnt/<pod_short_name>)"
    echo "  -n         : namespace (default: staging)"
    echo "  -c         : container name (for multi-container pods)"
    return 1
  fi

  # Resolve partial pod name
  local full_pod
  full_pod=$(command kubectl get po -n "$namespace" --no-headers -o custom-columns=":metadata.name" | grep "$pod" | head -1)
  if [[ -z "$full_pod" ]]; then
    echo "Error: No pod matching '$pod' in namespace '$namespace'" >&2
    return 1
  fi

  local short_name="${full_pod%%-[a-f0-9]*-[a-z0-9]*}"
  [[ -z "$short_name" ]] && short_name="$full_pod"
  mount_path="${mount_path:-$HOME/mnt/$short_name}"
  mkdir -p "$mount_path"

  # Build kubectl exec prefix
  local kexec="kubectl exec -i -n $namespace $full_pod"
  [[ -n "$container" ]] && kexec+=" -c $container"

  # Check if sftp-server exists in the pod
  if ! eval "command $kexec -- test -x /usr/lib/openssh/sftp-server" 2>/dev/null; then
    echo "Installing openssh-sftp-server in pod..."
    eval "command $kexec -- bash -c 'apt-get update -qq && apt-get install -y -qq openssh-sftp-server'" 2>&1 | tail -3
    if ! eval "command $kexec -- test -x /usr/lib/openssh/sftp-server" 2>/dev/null; then
      echo "Error: Failed to install sftp-server in the pod" >&2
      return 1
    fi
  fi

  # Start sshd inside the pod if not already running
  if ! eval "command $kexec -- pgrep -x sshd" >/dev/null 2>&1; then
    echo "Starting sshd in pod..."
    eval "command $kexec -- bash -c '
      ssh-keygen -A 2>/dev/null
      mkdir -p /run/sshd
      grep -q \"^PermitRootLogin yes\" /etc/ssh/sshd_config 2>/dev/null || echo \"PermitRootLogin yes\" >> /etc/ssh/sshd_config
      grep -q \"^PermitEmptyPasswords yes\" /etc/ssh/sshd_config 2>/dev/null || echo \"PermitEmptyPasswords yes\" >> /etc/ssh/sshd_config
      passwd -d root 2>/dev/null
      /usr/sbin/sshd -p 2222 -o ListenAddress=127.0.0.1
    '" 2>/dev/null
  fi

  # Pick an available local port for the forward
  local pf_port=2222
  while lsof -i :"$pf_port" >/dev/null 2>&1; do
    ((pf_port++))
  done

  # Start port-forward in background
  command kubectl port-forward -n "$namespace" "$full_pod" "$pf_port":2222 >/dev/null 2>&1 &
  local pf_pid=$!
  sleep 2

  if ! kill -0 "$pf_pid" 2>/dev/null; then
    echo "Error: port-forward failed to start" >&2
    return 1
  fi

  # Unmount stale mount if exists
  fusermount3 -uz "$mount_path" 2>/dev/null || fusermount -uz "$mount_path" 2>/dev/null

  # Mount via sshfs
  sshfs "root@127.0.0.1:/" "$mount_path" \
    -p "$pf_port" \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o reconnect,soft \
    -o cache=yes \
    -o password_stdin <<< ""

  if mountpoint -q "$mount_path" 2>/dev/null || mount | grep -q "$mount_path"; then
    echo "Mounted $full_pod:/ -> $mount_path"
    echo "  namespace: $namespace"
    echo "  port-forward PID: $pf_pid (local:$pf_port -> pod:2222)"
    echo "  Unmount with: kunmount $mount_path"
  else
    kill "$pf_pid" 2>/dev/null
    echo "Error: sshfs mount failed" >&2
    return 1
  fi
}

# Unmount a kmount'ed pod filesystem
# Usage: kunmount [local_path]
kunmount() {
  local mount_path="${1:-}"

  if [[ -z "$mount_path" ]]; then
    # List active kmount mounts under ~/mnt
    local mounts
    mounts=$(mount | grep "fuse.sshfs" | grep "$HOME/mnt" | awk '{print $3}')
    if [[ -z "$mounts" ]]; then
      echo "No active kmount mounts found"
      return 0
    fi
    echo "Active kmount mounts:"
    echo "$mounts" | while read -r m; do echo "  $m"; done
    echo ""
    echo "Usage: kunmount <mount_path>"
    return 1
  fi

  # Kill the port-forward associated with this mount
  local pf_info
  pf_info=$(mount | grep "fuse.sshfs" | grep "$mount_path")
  if [[ -n "$pf_info" ]]; then
    local port
    port=$(echo "$pf_info" | grep -oE '127\.0\.0\.1:[0-9]+' | head -1 | cut -d: -f2)
    if [[ -n "$port" ]]; then
      pkill -f "kubectl port-forward.*${port}:2222" 2>/dev/null
    fi
  fi

  # Unmount
  if fusermount3 -u "$mount_path" 2>/dev/null || fusermount -u "$mount_path" 2>/dev/null; then
    echo "Unmounted $mount_path"
  else
    fusermount3 -uz "$mount_path" 2>/dev/null || fusermount -uz "$mount_path" 2>/dev/null
    echo "Force-unmounted $mount_path"
  fi
}

# Helper to stop the k3s tunnel
k3s-tunnel-stop() {
  pkill -f "ssh.*-L.*6443:127.0.0.1:6443.*rye-opc" && echo "k3s tunnel stopped" || echo "No tunnel running"
}

# Check tunnel status
k3s-tunnel-status() {
  if pgrep -f "ssh.*-L.*6443:127.0.0.1:6443.*rye-opc" > /dev/null 2>&1; then
    echo "k3s tunnel is running (PID: $(pgrep -f 'ssh.*-L.*6443:127.0.0.1:6443.*rye-opc'))"
  else
    echo "k3s tunnel is not running"
  fi
}

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

