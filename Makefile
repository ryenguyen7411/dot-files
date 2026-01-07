# Makefile for dotfiles management with GNU Stow
# Usage: make install | make install-shell | make update | make lint

STOW := stow
STOW_FLAGS := -v --target=$(HOME)
STOW_ADOPT := -v --target=$(HOME) --adopt
PACKAGES := shell nvim kitty tmux git starship bat

.PHONY: all install install-adopt uninstall update lint help
.PHONY: install-shell install-nvim install-kitty install-tmux install-git install-ai install-tools install-starship install-bat
.PHONY: uninstall-shell uninstall-nvim uninstall-kitty uninstall-tmux uninstall-git uninstall-ai uninstall-starship uninstall-bat
.PHONY: backup check dry-run

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
	@echo "✓ Prerequisites OK"

dry-run:
	@echo "=== Dry run - no changes will be made ==="
	@echo ""
	@echo "Shell package:"
	@$(STOW) --simulate $(STOW_FLAGS) shell 2>&1 || true
	@echo ""
	@echo "Nvim package:"
	@$(STOW) --simulate $(STOW_FLAGS) nvim 2>&1 || true
	@echo ""
	@echo "Kitty package:"
	@$(STOW) --simulate $(STOW_FLAGS) kitty 2>&1 || true
	@echo ""
	@echo "Tmux package:"
	@$(STOW) --simulate $(STOW_FLAGS) tmux 2>&1 || true
	@echo ""
	@echo "Git package:"
	@$(STOW) --simulate $(STOW_FLAGS) git 2>&1 || true
	@echo ""
	@echo "Starship package:"
	@$(STOW) --simulate $(STOW_FLAGS) starship 2>&1 || true

backup:
	@echo "Backing up existing configs..."
	@mkdir -p $(HOME)/.dotfiles-backup
	@[ -f $(HOME)/.zshrc ] && cp $(HOME)/.zshrc $(HOME)/.dotfiles-backup/.zshrc.bak || true
	@[ -f $(HOME)/.gitconfig ] && cp $(HOME)/.gitconfig $(HOME)/.dotfiles-backup/.gitconfig.bak || true
	@[ -f $(HOME)/.tmux.conf.local ] && cp $(HOME)/.tmux.conf.local $(HOME)/.dotfiles-backup/.tmux.conf.local.bak || true
	@[ -d $(HOME)/.config/nvim ] && cp -r $(HOME)/.config/nvim $(HOME)/.dotfiles-backup/nvim.bak || true
	@[ -d $(HOME)/.config/kitty ] && cp -r $(HOME)/.config/kitty $(HOME)/.dotfiles-backup/kitty.bak || true
	@[ -d $(HOME)/.config/zsh ] && cp -r $(HOME)/.config/zsh $(HOME)/.dotfiles-backup/zsh.bak || true
	@echo "✓ Backup created at ~/.dotfiles-backup/"

#------------------------------------------------------------------------------
# Installation
#------------------------------------------------------------------------------

install: check install-shell install-nvim install-kitty install-tmux install-git install-starship install-ai install-tools install-bat
	@echo ""
	@echo "✓ All packages installed"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Copy local config:"
	@echo "     cp ~/.config/zsh/local.zsh.example ~/.config/zsh/local.zsh"
	@echo "     cp ~/.gitconfig-local.example ~/.gitconfig-local"
	@echo "  2. Set MACHINE_NAME in ~/.config/zsh/local.zsh"
	@echo "  3. Update gitconfig with your name and email, also add any other git config settings for this machine"
	@echo "  4. Reload shell: source ~/.zshrc"

# Install with force: removes existing files and creates symlinks
# Use this for first-time setup when you have existing configs
install-force: check backup
	@echo "Installing (removing existing files, backup created)..."
	@mkdir -p $(HOME)/.config/zsh $(HOME)/.config/kitty $(HOME)/.config/tmux-sessions
	@# Shell
	@rm -f $(HOME)/.zshrc
	@rm -rf $(HOME)/.config/zsh
	@# Nvim
	@rm -rf $(HOME)/.config/nvim
	@# Kitty
	@rm -f $(HOME)/.config/kitty/kitty.conf
	@# Tmux (tmux-sessions handled separately in install-tmux)
	@rm -f $(HOME)/.tmux.conf.local
	@# Git
	@rm -f $(HOME)/.gitconfig
	@# AI tools
	@rm -rf $(HOME)/.claude
	@rm -rf $(HOME)/.codex
	@rm -rf $(HOME)/.config/opencode
	@# Starship
	@rm -f $(HOME)/.config/starship.toml
	@# Bat
	@rm -rf $(HOME)/.config/bat
	@# Now stow everything
	$(STOW) $(STOW_FLAGS) shell
	$(STOW) $(STOW_FLAGS) nvim
	$(STOW) $(STOW_FLAGS) kitty
	$(STOW) $(STOW_FLAGS) tmux
	$(STOW) $(STOW_FLAGS) git
	$(STOW) $(STOW_FLAGS) starship
	$(STOW) $(STOW_FLAGS) bat
	$(STOW) $(STOW_FLAGS) ai-tools
	@if command -v bat >/dev/null 2>&1; then bat cache --build; fi
	@mkdir -p $(HOME)/.local/bin
	@ln -sf $(CURDIR)/tools/tms $(HOME)/.local/bin/tms
	@echo ""
	@echo "✓ All packages installed"
	@echo "✓ Backup available at ~/.dotfiles-backup/"

install-shell:
	@echo "Installing shell config..."
	@mkdir -p $(HOME)/.config/zsh
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
	@# .tmux.conf.local via stow
	$(STOW) $(STOW_FLAGS) tmux
	@# tmux-sessions: symlink machine-specific directory (requires MACHINE_NAME)
	@if [ -n "$$MACHINE_NAME" ]; then \
		MACHINE_DIR="$(CURDIR)/tmux-sessions/$$MACHINE_NAME"; \
		if [ ! -d "$$MACHINE_DIR" ]; then \
			echo "Creating new machine config from template..."; \
			cp -r "$(CURDIR)/tmux-sessions/default" "$$MACHINE_DIR"; \
		fi; \
		rm -rf $(HOME)/.config/tmux-sessions; \
		ln -sf "$$MACHINE_DIR" $(HOME)/.config/tmux-sessions; \
		echo "✓ Linked tmux-sessions for: $$MACHINE_NAME"; \
	else \
		echo "⚠ MACHINE_NAME not set, skipping tmux-sessions config"; \
		echo "  Set MACHINE_NAME in ~/.env.local and re-run"; \
	fi

install-git:
	@echo "Installing git config..."
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

install-ai:
	@echo "Installing AI tools config..."
	@mkdir -p $(HOME)/.config
	$(STOW) $(STOW_FLAGS) ai-tools

install-tools:
	@echo "Installing standalone tools..."
	@mkdir -p $(HOME)/.local/bin
	@ln -sf $(CURDIR)/tools/tms $(HOME)/.local/bin/tms
	@echo "✓ tms installed to ~/.local/bin/tms"

#------------------------------------------------------------------------------
# Uninstallation
#------------------------------------------------------------------------------

uninstall: uninstall-shell uninstall-nvim uninstall-kitty uninstall-tmux uninstall-git uninstall-starship uninstall-ai uninstall-bat
	@rm -f $(HOME)/.local/bin/tms
	@echo "✓ All packages uninstalled"

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

uninstall-ai:
	$(STOW) $(STOW_FLAGS) -D ai-tools || true

#------------------------------------------------------------------------------
# Restow (refresh symlinks)
#------------------------------------------------------------------------------

restow: uninstall install
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
	@echo "✓ Lua files are formatted correctly"

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
	@echo "  install-force    Install, replacing existing files (creates backup first)"
	@echo ""
	@echo "Installation:"
	@echo "  install          Install all packages (fails if conflicts exist)"
	@echo "  install-shell    Install shell config only"
	@echo "  install-nvim     Install neovim config only"
	@echo "  install-kitty    Install kitty config only"
	@echo "  install-tmux     Install tmux config only"
	@echo "  install-git      Install git config only"
	@echo "  install-starship Install starship config only"
	@echo "  install-bat      Install bat config and themes"
	@echo "  install-ai       Install AI tools config only"
	@echo "  install-tools    Install standalone tools (tms)"
	@echo ""
	@echo "Uninstallation:"
	@echo "  uninstall        Uninstall all packages"
	@echo "  restow           Uninstall and reinstall (refresh symlinks)"
	@echo ""
	@echo "Maintenance:"
	@echo "  update           Update Neovim plugins"
	@echo "  lint             Check Lua formatting"
	@echo "  lint-fix         Fix Lua formatting"
	@echo "  brew-install     Install packages from Brewfile"
	@echo "  brew-dump        Update Brewfile from installed packages"
