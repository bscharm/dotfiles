#### utility functions

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

#### Set zsh as default shell

set -e

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

#### Install Homebrew and go to town

if ! command -v brew >/dev/null; then
  fancy_echo "Installing Homebrew ..."
    curl -fsS \
      'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby
fi

fancy_echo "Updating Homebrew formulae ..."
brew update --force # https://github.com/Homebrew/brew/issues/1151

set +e

HOMEBREW_NO_AUTO_UPDATE=1 brew bundle --file=- <<EOF
tap 'homebrew/cask-fonts'

# Tools
brew 'git'
brew 'openssl'
brew 'tmux'
brew 'vim'
brew 'zsh'
brew 'bat'
brew 'fzf'
brew 'rbenv'
brew 'jq'

# GitHub
brew 'github/gh/gh'

# Unix Tools
brew 'coreutils'

# Databases
brew 'postgres', restart_service: :changed
brew 'redis', restart_service: :changed

# Apps
cask 'iterm2'
cask 'spotify'
cask 'spectacle'
cask 'jetbrains-toolbox'
cask 'brave-browser'
cask 'docker'
cask 'visual-studio-code'
cask 'virtualbox'
cask 'alfred'

# Languages
brew 'go'
brew 'node'
brew 'elixir'
cask 'java'

# Fonts
cask 'font-fira-code'
cask 'font-meslo-for-powerline'
EOF

set -e

#### Setup fzf

$(brew --prefix)/opt/fzf/install --all --no-bash

#### Install oh-my-zsh

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#### Set up ViM

mkdir -p $HOME/.vim/bundle
if ! [ -w "$HOME/.vim/bundle/Vundle.vim" ]; then
  git clone -q https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

#### Various Configurations

mkdir -p $HOME/workspace
append_to_zshrc '# added by dotfiles install script' 
append_to_zshrc 'export PATH="/usr/local/bin:$PATH"' 1
append_to_zshrc 'export GOPATH=$HOME/workspace/go'
append_to_zshrc "alias cat='bat'"
append_to_zshrc 'eval "$(rbenv init -)"'
append_to_zshrc 'prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"
  fi
}'
export PATH="/usr/local/bin:$PATH"

#### Generate SSH keys

if [ ! -f "$HOME/.ssh/github" ]; then
  ssh-keygen -f ~/.ssh/github -t rsa -P ''
fi

#### Move dotfiles into home directory

cp .vimrc "$HOME/.vimrc"
cp .ssh.config $HOME/.ssh/config
