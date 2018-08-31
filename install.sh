# utility functions

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\\n$fmt\\n" "$@"
}

append_to_zshrc() {
  local text="$1" zshrc
  local skip_new_line="${2:-0}"

  if [ -w "$HOME/.zshrc.local" ]; then
    zshrc="$HOME/.zshrc.local"
  else
    zshrc="$HOME/.zshrc"
  fi

  if ! grep -Fqs "$text" "$zshrc"; then
    if [ "$skip_new_line" -eq 1 ]; then
      printf "%s\\n" "$text" >> "$zshrc"
    else
      printf "\\n%s\\n" "$text" >> "$zshrc"
    fi
  fi
}

update_shell() {
  local shell_path;
  shell_path="$(command -v zsh)"

  fancy_echo "Changing your shell to zsh ..."
  if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
    fancy_echo "Adding '$shell_path' to /etc/shells"
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
  sudo chsh -s "$shell_path" "$USER"
}

set -e

# Set zsh as default shell

if [ ! -f "$HOME/.zshrc" ]; then
  touch "$HOME/.zshrc"
fi

case "$SHELL" in
  */zsh)
    if [ "$(command -v zsh)" != '/usr/local/bin/zsh' ] ; then
      update_shell
    fi
    ;;
  *)
    update_shell
    ;;
esac

# Install Homebrew and go to town

if ! command -v brew >/dev/null; then
  fancy_echo "Installing Homebrew ..."
    curl -fsS \
      'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby
fi

fancy_echo "Updating Homebrew formulae ..."
brew update --force # https://github.com/Homebrew/brew/issues/1151
brew bundle --file=- <<EOF
tap 'caskroom/cask' 
tap 'caskroom/fonts'

# Tools
brew 'git'
brew 'openssl'
brew 'tmux'
brew 'vim'
brew 'zsh'
brew 'bat'
brew 'fzf'

# GitHub
brew 'hub'

# Unix Tools
brew 'coreutils'

# Databases
brew 'postgres', restart_service: :changed
brew 'redis', restart_service: :changed

# Apps
cask 'google-chrome'
cask 'iterm2'
cask 'spotify'
cask 'spectacle'
cask 'flycut'
cask 'jetbrains-toolbox'
cask 'brave'

# Languages
brew 'go'
cask 'java'

# Fonts
cask 'font-fira-code'
cask 'font-meslo-for-powerline'
EOF

# Setup fzf

$(brew --prefix)/opt/fzf/install --all --no-bash

# Install oh-my-zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sed 's:env zsh::g' | sed 's:chsh -s .*$::g')"

# Set up ViM

mkdir -p $HOME/.vim/bundle
if ! [ -w "$HOME/.vim/bundle/Vundle.vim" ]; then
  git clone -q https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

# Add SSH keys
ssh-keygen -f ~/.ssh/gitub -t rsa -P ""

# Various Configurations
mkdir -p $HOME/dev
append_to_zshrc '# added by dotfiles install script' 
append_to_zshrc 'export PATH="/usr/local/bin:$PATH"' 1
append_to_zshrc 'export GOPATH=$HOME/dev/go'
append_to_zshrc "alias cat='bat'"
export PATH="/usr/local/bin:$PATH"

# Move dotfiles into home directory

cp .vimrc "$HOME/.vimrc"
