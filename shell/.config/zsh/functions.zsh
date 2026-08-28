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

# Detect git hosting provider from origin remote
git_provider() {
  local remote
  remote=$(git remote get-url origin 2>/dev/null) || return 1

  if [[ "$remote" == *github.com* ]]; then
    echo github
  elif [[ "$remote" == *gitlab* ]]; then
    echo gitlab
  elif [[ "$remote" == *git.begroup* ]]; then
    echo gitlab
  else
    echo unknown
  fi
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

# Push current branch and create PR/MR via official CLI (opens browser)
# Usage: gmr [target_branch]
#   gmr           → current branch → master
#   gmr develop   → current branch → develop
gmrnew() {
  local target="${1:-master}"
  local branch provider

  branch=$(git branch --show-current)
  if [[ -z "$branch" ]]; then
    echo "Error: Not on a branch (detached HEAD?)" >&2
    return 1
  fi

  git push -u origin "$branch" || return 1

  provider=$(git_provider) || true
  case "$provider" in
    github)
      command_exists gh || { echo "Error: gh not found (brew install gh)" >&2; return 1; }
      gh pr create \
        --base "$target" \
        --head "$branch" \
        --fill \
        --web
      ;;
    gitlab)
      command_exists glab || { echo "Error: glab not found (brew install glab)" >&2; return 1; }
      glab mr create \
        --source-branch "$branch" \
        --target-branch "$target" \
        --fill \
        --web
      ;;
    *)
      echo "Unsupported git provider" >&2
      return 1
      ;;
  esac
}

# Backport merged PR/MR to release branch and open release PR/MR in browser
# Usage: gls [release_branch]
#   gls                  → backport to release
#   gls release/2026.06  → backport to release/2026.06
gls() {
  local release_branch="${1:-release}"
  local source_branch backport_branch provider sha

  source_branch=$(git branch --show-current)
  if [[ -z "$source_branch" ]]; then
    echo "Error: Not on a branch (detached HEAD?)" >&2
    return 1
  fi

  provider=$(git_provider) || true
  case "$provider" in
    github)
      command_exists gh || { echo "Error: gh not found (brew install gh)" >&2; return 1; }
      sha=$(gh pr view "$source_branch" --json mergeCommit -q '.mergeCommit.oid' 2>/dev/null)
      ;;
    gitlab)
      command_exists glab || { echo "Error: glab not found (brew install glab)" >&2; return 1; }
      command_exists jq || { echo "Error: jq not found (brew install jq)" >&2; return 1; }
      sha=$(glab mr view "$source_branch" -F json 2>/dev/null | jq -r '.merge_commit_sha // empty')
      ;;
    *)
      echo "Unsupported git provider" >&2
      return 1
      ;;
  esac

  if [[ -z "$sha" || "$sha" == "null" ]]; then
    echo "Error: No merged PR/MR found for branch '$source_branch'" >&2
    return 1
  fi

  git fetch origin || return 1

  backport_branch="backport/${source_branch##*/}"
  echo "Creating $backport_branch from origin/$release_branch, cherry-picking $sha"

  git switch -c "$backport_branch" "origin/$release_branch" || return 1

  git cherry-pick "$sha" || {
    echo "Cherry-pick conflict — resolve and run: git cherry-pick --continue" >&2
    return 1
  }

  git push -u origin "$backport_branch" || return 1

  case "$provider" in
    github)
      gh pr create \
        --base "$release_branch" \
        --head "$backport_branch" \
        --title "[Release] ${source_branch}" \
        --body "Backport from ${source_branch}" \
        --web
      ;;
    gitlab)
      glab mr create \
        --source-branch "$backport_branch" \
        --target-branch "$release_branch" \
        --title "[Release] ${source_branch}" \
        --description "Backport from ${source_branch}" \
        --web
      ;;
  esac
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
# Docker Utilities
# ---------------------------

# Build, stop/remove, and run a frontend Docker container
# Usage: dockerexec <app_name> <port> [frontend_environment] [app_version] [custom_args...]
# Example: dockerexec finportal-frontend 3530 stage 1.99.9
# Example: dockerexec pad-admin 3560:8080 stage 1.0.0
# Example: dockerexec pad-admin 3560:8080 stage 1.0.0 IS_BIZOPS=true
# Example: dockerexec pad-admin 3560:8080 IS_BIZOPS=true --no-cache
dockerexec() {
  local app_name="$1"
  local port="$2"

  if [[ -z "$app_name" || -z "$port" ]]; then
    echo "Usage: dockerexec <app_name> <port> [frontend_environment] [app_version] [custom_args...]" >&2
    echo "  port                 : host port (e.g. 3530 -> 3530:80) or host:container mapping (e.g. 3560:8080)" >&2
    echo "  frontend_environment : default is 'stage'" >&2
    echo "  app_version          : default is '1.0.0'" >&2
    echo "  custom_args          : extra build args (e.g. IS_BIZOPS=true, --build-arg FOO=bar, --no-cache)" >&2
    return 1
  fi

  local env="stage"
  local version="1.0.0"
  local port_mapping="$port"
  if [[ "$port" != *:* ]]; then
    port_mapping="${port}:80"
  fi

  shift 2

  if [[ -n "$1" && "$1" != -* && "$1" != *=* ]]; then
    env="$1"
    shift
    if [[ -n "$1" && "$1" != -* && "$1" != *=* ]]; then
      version="$1"
      shift
    fi
  fi

  local extra_args=()
  local prev_was_build_arg=false

  while [[ $# -gt 0 ]]; do
    local arg="$1"
    if [[ "$prev_was_build_arg" == true ]]; then
      extra_args+=("$arg")
      prev_was_build_arg=false
    elif [[ "$arg" == "--build-arg" ]]; then
      extra_args+=("$arg")
      prev_was_build_arg=true
    elif [[ "$arg" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
      extra_args+=(--build-arg "$arg")
    else
      extra_args+=("$arg")
    fi
    shift
  done

  echo "Building Docker image '$app_name' (FRONTEND_ENVIRONMENT=$env, APP_VERSION=$version${extra_args:+ with extra args: ${extra_args[*]}})..."
  docker build \
    --build-arg FRONTEND_ENVIRONMENT="$env" \
    --build-arg APP_VERSION="$version" \
    "${extra_args[@]}" \
    -t "$app_name" . || return 1

  echo "Removing existing container '$app_name' (if any)..."
  docker rm -f "$app_name" >/dev/null 2>&1

  echo "Running container '$app_name' on port $port_mapping..."
  docker run --name "$app_name" -p "$port_mapping" "$app_name"
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
_kmount_ensure_sftp_server() {
  local namespace="$1"
  local pod="$2"
  local container="$3"
  local remote_sftp_server="${4:-/tmp/.kmount-sftp-server}"
  local host_sftp_server="/usr/lib/openssh/sftp-server"
  local kubectl_args=(-n "$namespace")

  if [[ -n "$container" ]]; then
    kubectl_args+=(-c "$container")
  fi

  if command kubectl exec "${kubectl_args[@]}" "$pod" -- test -x "$remote_sftp_server" >/dev/null 2>&1; then
    echo "$remote_sftp_server"
    return 0
  fi

  if [[ ! -x "$host_sftp_server" ]]; then
    echo "Error: local sftp-server not found at $host_sftp_server" >&2
    return 1
  fi

  echo "Copying sftp-server into pod..."
  command kubectl cp "${kubectl_args[@]}" "$host_sftp_server" "$namespace/$pod:$remote_sftp_server" >/dev/null
  command kubectl exec "${kubectl_args[@]}" "$pod" -- chmod 755 "$remote_sftp_server" >/dev/null 2>&1
  echo "$remote_sftp_server"
}

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
  full_pod=$(command kubectl get po -n "$namespace" --no-headers -o custom-columns=":metadata.name" | grep -m1 -- "$pod")
  if [[ -z "$full_pod" ]]; then
    echo "Error: No pod matching '$pod' in namespace '$namespace'" >&2
    return 1
  fi

  local short_name="${full_pod%%-[a-f0-9]*-[a-z0-9]*}"
  [[ -z "$short_name" ]] && short_name="$full_pod"
  mount_path="${mount_path:-$HOME/mnt/$short_name}"
  mkdir -p "$mount_path"

  local remote_sftp_server
  remote_sftp_server=$(_kmount_ensure_sftp_server "$namespace" "$full_pod" "$container") || return 1

  # Unmount stale mount if exists
  fusermount3 -uz "$mount_path" 2>/dev/null || fusermount -uz "$mount_path" 2>/dev/null

  # Mount via sshfs over kubectl exec, so it works without root in the pod.
  local ssh_command
  ssh_command="/tmp/.kmount-sshfs-${namespace}-${full_pod}${container:+-${container}}.sh"
  cat > "$ssh_command" <<EOF
#!/usr/bin/env bash
remote_command="\${@: -1}"
exec kubectl exec -i -n "$namespace"${container:+ -c "$container"} "$full_pod" -- "\$remote_command"
EOF
  chmod 755 "$ssh_command"

  sshfs ":/" "$mount_path" \
    -o ssh_command="$ssh_command" \
    -o sftp_server="$remote_sftp_server" \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o reconnect \
    -o cache=yes \
    -o no_check_root

  if mountpoint -q "$mount_path" 2>/dev/null || mount | grep -q "$mount_path"; then
    echo "Mounted $full_pod:/ -> $mount_path"
    echo "  namespace: $namespace"
    echo "  Unmount with: kunmount $mount_path"
  else
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

