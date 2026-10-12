# Makefile for dotfiles management with GNU Stow
# Usage: make install | make install-shell | make update | make lint

STOW := stow
STOW_FLAGS := -v --target=$(HOME)
PACKAGES := shell nvim kitty tmux git starship bat raycast
BACKUP_DIR := $(HOME)/.dotfiles-backup

# Standalone tools linked into ~/.local/bin
SWIFT_TOOLS := imgcopy jump-display jump-desktop clean-url link-router
SCRIPT_TOOLS := tms shottr-optimize shottr-upload
SWIFT_BINS := $(addprefix tools/,$(SWIFT_TOOLS))

# Bash scripts checked by `make lint` (zsh files are syntax-checked with zsh -n)
SHELL_SCRIPTS := tools/tms tools/shottr-optimize tools/shottr-upload tools/install-ubuntu-server.sh \
	$(wildcard raycast/.config/raycast/scripts/*.sh)
ZSH_FILES := shell/.zshrc shell/.zprofile $(wildcard shell/.config/zsh/*.zsh) \
	shell/.config/zsh/claude-popup shell/.config/zsh/opencode-popup

.PHONY: all help check dry-run backup
.PHONY: install install-force install-shell install-nvim install-kitty install-tmux install-git install-starship
.PHONY: install-bat install-raycast install-ssh install-tools install-search install-ubuntu-server
.PHONY: install-jump-desktop-service uninstall-jump-desktop-service install-zinit install-difftastic
.PHONY: uninstall uninstall-shell uninstall-nvim uninstall-kitty uninstall-tmux uninstall-git uninstall-starship
.PHONY: uninstall-bat uninstall-ssh uninstall-raycast uninstall-search restow update lint lint-fix brew-install brew-dump brew-check

# Default target
all: help

#------------------------------------------------------------------------------
# Pre-flight Checks
#------------------------------------------------------------------------------

check:
	@echo "Checking prerequisites..."
	@command -v stow >/dev/null 2>&1 || { echo "✗ stow not found. Run: brew install stow"; exit 1; }
	@command -v nvim >/dev/null 2>&1 || echo "⚠ nvim not found (optional)"
	@command -v tmux >/dev/null 2>&1 || echo "⚠ tmux not found (optional)"
	@command -v yq >/dev/null 2>&1 || echo "⚠ yq not found (tms needs it)"
	@echo "✓ Prerequisites OK"

dry-run:
	@echo "=== Dry run - no changes will be made ==="
	@for pkg in $(PACKAGES); do \
		echo ""; echo "$$pkg package:"; \
		$(STOW) --simulate $(STOW_FLAGS) $$pkg 2>&1 || true; \
	done

# Copies every config `make install` may replace (only real files/dirs; symlinks are ours)
backup:
	@echo "Backing up existing configs to $(BACKUP_DIR)/ ..."
	@mkdir -p $(BACKUP_DIR)
	@for f in .zshrc .zprofile .gitconfig .config/git/ignore .tmux.conf .tmux.conf.local .ssh/config \
		.config/nvim .config/kitty .config/zsh .config/bat .config/starship.toml .config/raycast/scripts; do \
		if [ -e "$(HOME)/$$f" ] && [ ! -L "$(HOME)/$$f" ]; then \
			mkdir -p "$(BACKUP_DIR)/$$(dirname $$f)"; \
			cp -R "$(HOME)/$$f" "$(BACKUP_DIR)/$$f.bak" && echo "  $$f"; \
		fi; \
	done
	@echo "✓ Backup done"

#------------------------------------------------------------------------------
# Installation
#------------------------------------------------------------------------------

install: check install-shell install-nvim install-kitty install-tmux install-git install-starship install-tools install-jump-desktop-service install-raycast install-bat install-search install-ssh
	@echo ""
	@echo "✓ All packages installed"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Copy local config:"
	@echo "     cp ~/.config/zsh/local.zsh.example ~/.config/zsh/local.zsh"
	@echo "     cp ~/.gitconfig-local.example ~/.gitconfig-local"
	@echo "     cp ~/.gitconfig-work.example ~/.gitconfig-work   # identity for ~/projects/be/"
	@echo "  2. Set MACHINE_NAME in ~/.config/zsh/local.zsh"
	@echo "  3. Reload shell: exec zsh"

install-ubuntu-server:
	@echo "Installing dotfiles for Ubuntu server (shell + nvim only)..."
	@./tools/install-ubuntu-server.sh

# First-time setup over existing configs: back them up, remove them, then install
install-force: check backup
	@echo "Replacing existing configs (backup in $(BACKUP_DIR))..."
	@rm -f $(HOME)/.zshrc $(HOME)/.zprofile $(HOME)/.gitconfig $(HOME)/.config/git/ignore
	@rm -f $(HOME)/.tmux.conf.local $(HOME)/.config/kitty/kitty.conf $(HOME)/.config/starship.toml
	@rm -rf $(HOME)/.config/zsh $(HOME)/.config/nvim $(HOME)/.config/bat $(HOME)/.config/raycast/scripts
	@$(MAKE) install

# Stow helper: move a real (non-symlink) file out of the way so stow can link it
define move_aside
	@if [ -e "$(HOME)/$(1)" ] && [ ! -L "$(HOME)/$(1)" ]; then \
		mkdir -p "$(BACKUP_DIR)/$$(dirname $(1))"; \
		mv "$(HOME)/$(1)" "$(BACKUP_DIR)/$(1).bak"; \
		echo "  moved existing ~/$(1) to $(BACKUP_DIR)/$(1).bak"; \
	fi
endef

install-shell:
	@echo "Installing shell config..."
	@mkdir -p $(HOME)/.config/zsh
	$(call move_aside,.zprofile)
	$(STOW) $(STOW_FLAGS) shell

install-nvim:
	@echo "Installing neovim config..."
	@mkdir -p $(HOME)/.config
	$(STOW) $(STOW_FLAGS) nvim

install-kitty:
	@echo "Installing kitty config..."
	@mkdir -p $(HOME)/.config/kitty
	$(STOW) $(STOW_FLAGS) kitty

install-tmux:
	@echo "Installing tmux config..."
	@# Oh my tmux! provides ~/.tmux.conf, which loads our ~/.tmux.conf.local
	@if [ ! -d "$(HOME)/.tmux" ]; then \
		git clone --single-branch https://github.com/gpakosz/.tmux.git "$(HOME)/.tmux"; \
	fi
	@if [ ! -e "$(HOME)/.tmux.conf" ]; then ln -s .tmux/.tmux.conf "$(HOME)/.tmux.conf"; fi
	$(STOW) $(STOW_FLAGS) tmux
	@# tmux-sessions: symlink machine-specific directory (requires MACHINE_NAME)
	@if [ -n "$$MACHINE_NAME" ]; then \
		MACHINE_DIR="$(CURDIR)/tmux-sessions/$$MACHINE_NAME"; \
		if [ ! -d "$$MACHINE_DIR" ]; then \
			echo "Creating new machine config from template..."; \
			cp -r "$(CURDIR)/tmux-sessions/default" "$$MACHINE_DIR"; \
		fi; \
		rm -f $(HOME)/.config/tmux-sessions; \
		ln -sfn "$$MACHINE_DIR" $(HOME)/.config/tmux-sessions; \
		echo "✓ Linked tmux-sessions for: $$MACHINE_NAME"; \
	else \
		echo "⚠ MACHINE_NAME not set, skipping tmux-sessions config"; \
		echo "  Set MACHINE_NAME in ~/.config/zsh/local.zsh, open a new shell and re-run"; \
	fi

install-git:
	@echo "Installing git config..."
	@mkdir -p $(HOME)/.config/git
	$(call move_aside,.config/git/ignore)
	$(STOW) $(STOW_FLAGS) git

install-starship:
	@echo "Installing starship config..."
	$(STOW) $(STOW_FLAGS) starship

install-bat:
	@echo "Installing bat config..."
	@mkdir -p $(HOME)/.config/bat/themes
	$(STOW) $(STOW_FLAGS) bat
	@if command -v bat >/dev/null 2>&1; then \
		echo "Building bat theme cache..."; \
		bat cache --build; \
		echo "✓ bat themes installed"; \
	else \
		echo "⚠ bat not found, skipping cache build (run 'bat cache --build' after installing bat)"; \
	fi

# Global ignore list for the Neovim file/grep pickers (they run fd/rg with --no-ignore)
install-search:
	@echo "Installing fd/rg ignore files..."
	@mkdir -p $(HOME)/.config/fd $(HOME)/.config/rg
	@ln -sfn $(CURDIR)/.ignore $(HOME)/.config/fd/.fdignore
	@ln -sfn $(CURDIR)/.ignore $(HOME)/.config/rg/.rgignore
	@echo "✓ ~/.config/fd/.fdignore and ~/.config/rg/.rgignore -> .ignore"

install-ssh:
	@if [ ! -f "$(CURDIR)/ssh/.ssh/config.local" ]; then \
		echo "⚠ Skipping SSH config: ssh/.ssh/config.local not found"; \
		echo "  Create it from the template, then run: make install-ssh"; \
		echo "    cp ssh/.ssh/config.example ssh/.ssh/config.local"; \
	else \
		echo "Installing SSH config with multiplexing..."; \
		mkdir -p $(HOME)/.ssh/sockets; \
		chmod 700 $(HOME)/.ssh $(HOME)/.ssh/sockets; \
		if [ -e $(HOME)/.ssh/config ] && [ ! -L $(HOME)/.ssh/config ]; then \
			mkdir -p $(BACKUP_DIR)/.ssh; \
			mv $(HOME)/.ssh/config $(BACKUP_DIR)/.ssh/config.bak; \
			echo "  moved existing ~/.ssh/config to $(BACKUP_DIR)/.ssh/config.bak"; \
		fi; \
		ln -sfn $(CURDIR)/ssh/.ssh/config.local $(HOME)/.ssh/config; \
		chmod 600 $(CURDIR)/ssh/.ssh/config.local; \
		echo "✓ SSH config installed with multiplexing enabled"; \
	fi

# Swift tools are rebuilt only when their source changes; compile errors stop the build
tools/%: tools/%.swift
	swiftc -O $< -o $@

tools/jump-desktop: tools/jump-desktop.swift tools/jump-desktop-Info.plist
	swiftc -O -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker tools/jump-desktop-Info.plist $< -o $@
	codesign -s - --force --identifier com.colorye.jump-desktop $@

install-tools: $(SWIFT_BINS)
	@echo "Installing standalone tools..."
	@mkdir -p $(HOME)/.local/bin
	@for tool in $(SWIFT_TOOLS) $(SCRIPT_TOOLS); do ln -sf $(CURDIR)/tools/$$tool $(HOME)/.local/bin/$$tool; done
	@echo "✓ Standalone tools installed to ~/.local/bin"

install-raycast:
	@echo "Installing Raycast script commands..."
	@mkdir -p $(HOME)/.config/raycast
	@chmod +x $(CURDIR)/raycast/.config/raycast/scripts/*.sh 2>/dev/null || true
	$(STOW) $(STOW_FLAGS) raycast
	@echo "✓ Raycast scripts installed to ~/.config/raycast/scripts"

#------------------------------------------------------------------------------
# LaunchAgent Services
#------------------------------------------------------------------------------

install-jump-desktop-service:
	@if [ "$$(uname)" = "Darwin" ]; then \
		echo "Installing jump-desktop background service..."; \
		mkdir -p $(HOME)/Library/LaunchAgents; \
		rm -f $(HOME)/Library/LaunchAgents/com.colorye.jump-desktop.plist; \
		sed 's|__HOME__|$(HOME)|g; s|/Users/[^/]*/\.local|$(HOME)/.local|g' $(CURDIR)/launchd/com.colorye.jump-desktop.plist > $(HOME)/Library/LaunchAgents/com.colorye.jump-desktop.plist; \
		launchctl bootout gui/$$(id -u) $(HOME)/Library/LaunchAgents/com.colorye.jump-desktop.plist 2>/dev/null || true; \
		launchctl bootstrap gui/$$(id -u) $(HOME)/Library/LaunchAgents/com.colorye.jump-desktop.plist 2>/dev/null || \
			launchctl load $(HOME)/Library/LaunchAgents/com.colorye.jump-desktop.plist; \
		echo "✓ jump-desktop watcher service installed and loaded"; \
	fi

uninstall-jump-desktop-service:
	@if [ "$$(uname)" = "Darwin" ]; then \
		echo "Stopping and removing jump-desktop service..."; \
		launchctl bootout gui/$$(id -u) $(HOME)/Library/LaunchAgents/com.colorye.jump-desktop.plist 2>/dev/null || \
			launchctl unload $(HOME)/Library/LaunchAgents/com.colorye.jump-desktop.plist 2>/dev/null || true; \
		rm -f $(HOME)/Library/LaunchAgents/com.colorye.jump-desktop.plist; \
		echo "✓ jump-desktop service uninstalled"; \
	fi

#------------------------------------------------------------------------------
# Shell Plugin Manager (Zinit)
#------------------------------------------------------------------------------

ZINIT_HOME := $(HOME)/.local/share/zinit/zinit.git

install-zinit:
	@echo "Installing Zinit plugin manager..."
	@if [ -d "$(ZINIT_HOME)" ]; then \
		echo "✓ Zinit already installed at $(ZINIT_HOME)"; \
	else \
		mkdir -p "$$(dirname $(ZINIT_HOME))"; \
		git clone https://github.com/zdharma-continuum/zinit.git "$(ZINIT_HOME)"; \
		echo "✓ Zinit installed"; \
	fi

#------------------------------------------------------------------------------
# Git Tools
#------------------------------------------------------------------------------

install-difftastic:
	@echo "Installing difftastic (structural diff)..."
	@if command -v brew >/dev/null 2>&1; then \
		brew install difftastic; \
	elif command -v cargo >/dev/null 2>&1; then \
		cargo install difftastic; \
	else \
		echo "✗ Neither brew nor cargo found. Install manually: https://difftastic.wilfred.me.uk/"; \
		exit 1; \
	fi
	@echo "✓ difftastic installed (use: git difft)"

#------------------------------------------------------------------------------
# Uninstallation
#------------------------------------------------------------------------------

uninstall: uninstall-jump-desktop-service uninstall-shell uninstall-nvim uninstall-kitty uninstall-tmux uninstall-git uninstall-starship uninstall-bat uninstall-ssh uninstall-raycast uninstall-search
	@for tool in $(SWIFT_TOOLS) $(SCRIPT_TOOLS); do rm -f $(HOME)/.local/bin/$$tool; done
	@echo "✓ All packages uninstalled"

uninstall-raycast:
	@echo "Uninstalling Raycast scripts..."
	$(STOW) $(STOW_FLAGS) -D raycast || true
	@echo "✓ Raycast scripts uninstalled"

uninstall-shell:
	$(STOW) $(STOW_FLAGS) -D shell || true

uninstall-nvim:
	$(STOW) $(STOW_FLAGS) -D nvim || true

uninstall-kitty:
	$(STOW) $(STOW_FLAGS) -D kitty || true

uninstall-tmux:
	$(STOW) $(STOW_FLAGS) -D tmux || true
	@rm -f $(HOME)/.config/tmux-sessions

uninstall-git:
	$(STOW) $(STOW_FLAGS) -D git || true

uninstall-starship:
	$(STOW) $(STOW_FLAGS) -D starship || true

uninstall-bat:
	$(STOW) $(STOW_FLAGS) -D bat || true

uninstall-search:
	@rm -f $(HOME)/.config/fd/.fdignore $(HOME)/.config/rg/.rgignore

uninstall-ssh:
	@if [ -L $(HOME)/.ssh/config ]; then rm -f $(HOME)/.ssh/config; fi

#------------------------------------------------------------------------------
# Restow (refresh symlinks)
#------------------------------------------------------------------------------

restow:
	@for pkg in $(PACKAGES); do $(STOW) $(STOW_FLAGS) --restow $$pkg; done
	@echo "✓ All packages restowed"

#------------------------------------------------------------------------------
# Maintenance
#------------------------------------------------------------------------------

update:
	@echo "Updating Neovim plugins..."
	nvim --headless "+Lazy! sync" +qa
	@echo "✓ Neovim plugins updated"

lint:
	@echo "Checking Lua formatting..."
	stylua --check nvim/.config/nvim/
	@echo "Checking shell scripts..."
	shellcheck --severity=warning $(SHELL_SCRIPTS)
	@for f in $(ZSH_FILES); do zsh -n "$$f" || exit 1; done
	@echo "✓ Lint passed"

lint-fix:
	@echo "Fixing Lua formatting..."
	stylua nvim/.config/nvim/
	@echo "✓ Lua files formatted"

brew-install:
	@echo "Installing packages from Brewfile..."
	brew bundle
	@echo "✓ Brew packages installed"

brew-dump:
	@echo "Updating Brewfile..."
	brew bundle dump --force
	@echo "✓ Brewfile updated"

# Drift check: what the Brewfile lacks (installed but unlisted) and what isn't installed
brew-check:
	@echo "Installed but not in Brewfile:"
	@brew bundle cleanup || true
	@echo ""
	@brew bundle check --verbose || true

#------------------------------------------------------------------------------
# Help
#------------------------------------------------------------------------------

help:
	@echo "Dotfiles Management with GNU Stow"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "First-time Setup:"
	@echo "  check            Check prerequisites (stow, etc.)"
	@echo "  dry-run          Preview what stow would do"
	@echo "  backup           Backup existing configs to ~/.dotfiles-backup/"
	@echo "  install-force    Back up, remove existing configs, then install"
	@echo ""
	@echo "Installation:"
	@echo "  install          Install all packages"
	@echo "  install-shell    Install shell config (.zshrc, .zprofile, ~/.config/zsh)"
	@echo "  install-nvim     Install neovim config only"
	@echo "  install-kitty    Install kitty config only"
	@echo "  install-tmux     Install tmux config (+ Oh my tmux! if missing)"
	@echo "  install-git      Install git config + global ignore"
	@echo "  install-starship Install starship config only"
	@echo "  install-bat      Install bat config and themes"
	@echo "  install-raycast  Install Raycast script commands"
	@echo "  install-search   Link fd/rg ignore files used by the Neovim pickers"
	@echo "  install-ssh      Install SSH config with multiplexing"
	@echo "  install-tools    Build (if changed) and link standalone tools"
	@echo "  install-ubuntu-server Install minimal shell+nvim for Ubuntu server"
	@echo ""
	@echo "Uninstallation:"
	@echo "  uninstall        Uninstall all packages"
	@echo "  restow           Refresh all stow symlinks"
	@echo ""
	@echo "Extras:"
	@echo "  install-zinit    Install Zinit plugin manager for Zsh"
	@echo "  install-difftastic Install difftastic (structural diff tool)"
	@echo ""
	@echo "Maintenance:"
	@echo "  update           Update Neovim plugins"
	@echo "  lint             stylua + shellcheck + zsh syntax check"
	@echo "  lint-fix         Fix Lua formatting"
	@echo "  brew-install     Install packages from Brewfile"
	@echo "  brew-dump        Update Brewfile from installed packages"
	@echo "  brew-check       Show drift between the Brewfile and what's installed"
