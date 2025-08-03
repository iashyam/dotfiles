#!/usr/bin/env bash

set -euo pipefail

# =========================
# Detect OS and Package Manager
# =========================

detect_os() {
  OS="unknown"
  PKG="unknown"

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    if command -v apt &>/dev/null; then
      PKG="apt"
    elif command -v pacman &>/dev/null; then
      PKG="pacman"
    elif command -v dnf &>/dev/null; then
      PKG="dnf"
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    if ! command -v brew &>/dev/null; then
      echo "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    PKG="brew"
  fi

  echo "📟 Detected OS: $OS, Package manager: $PKG"
}

# =========================
# Install Basic Packages
# =========================

install_packages() {
  echo "📦 Installing base packages..."

  case $PKG in
    apt)
      sudo apt update
      sudo apt install -y git curl wget zsh python3 python3-pip
      ;;
    pacman)
      sudo pacman -Syu --noconfirm git curl wget zsh python
      ;;
    dnf)
      sudo dnf install -y git curl wget zsh python3 python3-pip
      ;;
    brew)
      brew install git curl wget zsh python
      ;;
    *)
      echo "⚠️ Unknown package manager: $PKG"
      ;;
  esac
}


# =========================
# Install Anaconda
# =========================

install_anaconda() {
  echo "📦 Installing Anaconda..."

  if command -v conda &>/dev/null; then
    echo "✅ Anaconda already installed."
    return
  fi

  ANACONDA_SCRIPT="Anaconda3-latest-Linux-x86_64.sh"
  [[ "$OS" == "macos" ]] && ANACONDA_SCRIPT="Anaconda3-latest-MacOSX-x86_64.sh"

  curl -O https://repo.anaconda.com/archive/$ANACONDA_SCRIPT
  bash $ANACONDA_SCRIPT -b -p "$HOME/anaconda3"
  eval "$($HOME/anaconda3/bin/conda shell.bash hook)"
  conda init
}

# =========================
# Install Go
# =========================

install_go() {
  echo "📦 Installing Go..."

  if command -v go &>/dev/null; then
    echo "✅ Go already installed."
    return
  fi

  GO_VERSION=$(curl -s https://go.dev/VERSION?m=text)
  GO_TARBALL="${GO_VERSION}.linux-amd64.tar.gz"
  [[ "$OS" == "macos" ]] && GO_TARBALL="${GO_VERSION}.darwin-amd64.tar.gz"

  curl -OL "https://dl.google.com/go/$GO_TARBALL"
  sudo tar -C /usr/local -xzf "$GO_TARBALL"

  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
}

# =========================
# Install VS Code
# =========================

install_vscode() {
  echo "🖥️ Installing VS Code..."

  if command -v code &>/dev/null; then
    echo "✅ VS Code already installed."
    return
  fi

  case $PKG in
    apt)
      wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
      sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
      sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
      sudo apt update
      sudo apt install -y code
      ;;
    pacman)
      sudo pacman -S --noconfirm code
      ;;
    brew)
      brew install --cask visual-studio-code
      ;;
    *)
      echo "⚠️ Install VS Code manually."
      ;;
  esac
}

# =========================
# Install Kitty
# =========================

install_kitty() {
  echo "🐱 Installing Kitty..."

  if command -v kitty &>/dev/null; then
    echo "✅ Kitty already installed."
    return
  fi

  if [[ "$OS" == "macos" ]]; then
    brew install --cask kitty
  else
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    mkdir -p ~/.local/bin
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/kitty
    echo 'export PATH="$HOME/.local/kitty.app/bin:$PATH"' >> ~/.bashrc
  fi
}

# =========================
# Install Vim
# =========================

install_vim() {
  echo "📝 Installing Vim..."

  case $PKG in
    apt|dnf)
      sudo "$PKG" install -y vim
      ;;
    pacman)
      sudo pacman -S --noconfirm vim
      ;;
    brew)
      brew install vim
      ;;
    *)
      echo "⚠️ Install Vim manually."
      ;;
  esac
}

# =========================
# Install Tmux
# =========================

install_tmux() {
  echo "🧱 Installing Tmux..."

  case $PKG in
    apt|dnf)
      sudo "$PKG" install -y tmux
      ;;
    pacman)
      sudo pacman -S --noconfirm tmux
      ;;
    brew)
      brew install tmux
      ;;
    *)
      echo "⚠️ Install Tmux manually."
      ;;
  esac
}

# =========================
# Generate Git SSH Key
# =========================

generate_ssh_key() {
  echo "🔐 Setting up Git SSH key..."

  if [[ -f "$HOME/.ssh/id_rsa" ]]; then
    echo "✅ SSH key already exists."
    return
  fi

  read -p "Enter your Git email: " email
  ssh-keygen -t rsa -b 4096 -C "$email" -f "$HOME/.ssh/id_rsa" -N ""
  eval "$(ssh-agent -s)"
  ssh-add "$HOME/.ssh/id_rsa"

  echo "🧷 Public key:"
  cat "$HOME/.ssh/id_rsa.pub"
  echo "🔁 Add this to GitHub/GitLab → SSH keys"
}

# =========================
# Setup Zsh + Oh My Zsh
# =========================

setup_shell() {
  echo "💻 Setting up Zsh and Oh My Zsh..."

  if ! command -v zsh &>/dev/null; then
    echo "⏬ Zsh not found. Installing..."

    case $PKG in
      apt|dnf)
        sudo "$PKG" install -y zsh
        ;;
      pacman)
        sudo pacman -S --noconfirm zsh
        ;;
      brew)
        brew install zsh
        ;;
      *)
        echo "⚠️ Unknown package manager. Install Zsh manually."
        return
        ;;
    esac
  fi

  current_shell=$(basename "$SHELL")
  if [[ "$current_shell" != "zsh" ]]; then
    echo "⚙️ Changing default shell to Zsh..."
    chsh -s "$(which zsh)"
  fi

  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "✨ Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  echo "✅ Zsh is set up. Restart your terminal or log out and in again."
}

# =========================
# Clone Dotfiles (Optional)
# =========================

clone_dotfiles() {
  read -p "Do you want to clone your dotfiles repo? (y/n): " choice
  if [[ "$choice" == "y" ]]; then
    read -p "Enter Git repo URL: " repo_url
    git clone "$repo_url" "$HOME/dotfiles"
    echo "✅ Dotfiles cloned to ~/dotfiles"
  fi
}

# =========================
# Main
# =========================

main() {
  detect_os
  install_packages
  install_anaconda
  install_go
  install_vscode
  install_kitty
  install_vim
  install_tmux
  generate_ssh_key
  setup_shell
  clone_dotfiles

  echo -e "\n✅ Full setup complete. Restart your shell to apply everything!"
}

main "$@"

