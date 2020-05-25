#!/bin/bash

# Utils
function is_installed {
  # set to 1 initially
  local return_=1
  # set to 0 if not found
  type $1 >/dev/null 2>&1 || { local return_=0;  }
  # return
  echo "$return_"
}

function install_macos {
  if [[ $OSTYPE != darwin* ]]; then
    return
  fi
  echo "MacOS detected"
  xcode-select --install

  if [ "$(is_installed brew)" == "0" ]; then
    echo "Installing Homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  if [ $TERM_PROGRAM != "iTerm.app" ]; then
    echo "Installing iTerm2"
    brew tap caskroom/cask
    brew cask install iterm2
  fi

  if [ "$(is_installed zsh)" == "0" ]; then
    echo "Installing zsh"
    brew install zsh zsh-completions
  fi

  if [ "$(is_installed ag)" == "0" ]; then
    echo "Installing The silver searcher"
    brew install the_silver_searcher
  fi

  if [ "$(is_installed fzf)" == "0" ]; then
    echo "Installing fzf"
    brew install fzf
  fi

  if [ "$(is_installed tmux)" == "0" ]; then
    echo "Installing tmux"
    brew install tmux
    echo "Installing reattach-to-user-namespace"
    brew install reattach-to-user-namespace
    echo "Installing tmux-plugin-manager"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi

  if [ "$(is_installed git)" == "0" ]; then
    echo "Installing Git"
    brew install git
  fi

  if [ "$(is_installed node)" == "0" ]; then
    echo "Installing Node"
    brew install node
  fi

  if [ "$(is_installed nvim)" == "0" ]; then
    echo "Install neovim"
    brew install neovim
    if [ "$(is_installed pip3)" == "1" ]; then
      pip3 install neovim --upgrade
    fi
  fi
}



function install_ubuntu {

  echo "ubuntu detected"
  sudo apt-get update


  # install python
  dpkg -s python3.6 &> /dev/null
  if [ $? -ne 0 ]
      then
          echo "-----------------------installed python--------------------------------"
          sudo apt-get update
          sudo apt-get install python3.6

      else
          echo    "installed"
  fi


  # install zsh
  dpkg -s zsh &> /dev/null
  if [ $? -ne 0 ]
      then
          echo "-----------------------installed zsh--------------------------------"
          sudo apt-get update
          sudo apt-get install zsh
          sudo apt-get install zsh-completions

      else
          echo    "installed"
  fi

  # install fzf
  dpkg -s fzf &> /dev/null
  if [ $? -ne 0 ]
      then
          echo "-----------------------installed fzf--------------------------------"
          sudo apt-get update
          sudo apt-get install fzf
      else
          echo    "installed"
  fi


  # install ag
  dpkg -s ag &> /dev/null
  if [ $? -ne 0 ]
      then
          echo "-----------------------installed ag--------------------------------"
          sudo apt-get update
          sudo apt-get install the_silver_searcher
      else
          echo    "installed"
  fi
  # install tmux
  dpkg -s tmux &> /dev/null
  if [ $? -ne 0 ]
      then
          echo "-----------------------installed tmux--------------------------------"
          sudo apt-get update
          sudo apt-get install tmux
          echo "Installing reattach-to-user-namespace"
          sudo apt-get install reattach-to-user-namespace
          echo "Installing tmux-plugin-manager"
          git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
      else
          echo    "installed"
  fi

  # install git
  dpkg -s git &> /dev/null
  if [ $? -ne 0 ]
      then
          echo "-----------------------installed git--------------------------------"
          sudo apt-get update
          sudo apt-get install git
      else
          echo    "installed"
  fi
  # install node
  dpkg -s node &> /dev/null
  if [ $? -ne 0 ]
      then
          echo "-----------------------installed node--------------------------------"
          sudo apt-get update
          sudo apt-get install node
      else
          echo    "installed"
  fi
  # install npm
  dpkg -s npm &> /dev/null
  if [ $? -ne 0 ]
      then
          echo "-----------------------installed npm--------------------------------"
          sudo apt-get update
          sudo apt-get install npm
      else
          echo    "installed"
  fi
  # install nvim
  dpkg -s nvim &> /dev/null
  if [ $? -ne 0 ]
      then
          echo "-----------------------installed nvim--------------------------------"
          sudo apt-get update
          sudo apt-get install neovim
      else
          echo    "installed"
  fi
}


function backup {
  echo "Backing up dotfiles"
  local current_date=$(date +%s)
  local backup_dir=dotfiles_$current_date

  mkdir ~/$backup_dir

  mv ~/.zshrc ~/$backup_dir/.zshrc
  mv ~/.tmux.conf ~/$backup_dir/.tmux.conf
  mv ~/.vim ~/$backup_dir/.vim
  mv ~/.vimrc ~/$backup_dir/.vimrc
  mv ~/.vimrc.bundles ~/$backup_dir/.vimrc.bundles
}

function link_dotfiles {
  echo "Linking dotfiles"

  ln -s $(pwd)/zshrc ~/.zshrc
  ln -s $(pwd)/tmux.conf ~/.tmux.conf
  ln -s $(pwd)/vim ~/.vim
  ln -s $(pwd)/vimrc ~/.vimrc
  ln -s $(pwd)/vimrc.bundles ~/.vimrc.bundles

  echo "Installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  if [ ! -d "$ZSH/custom/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions"
    git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH/custom/plugins/zsh-autosuggestions
  fi

  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  rm -rf $HOME/.config/nvim/init.vim
  rm -rf $HOME/.config/nvim
  mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}
  ln -s $(pwd)/vim $XDG_CONFIG_HOME/nvim
  ln -s $(pwd)/vimrc $XDG_CONFIG_HOME/nvim/init.vim
}

while test $# -gt 0; do
  case "$1" in
    --help)
      echo "Help"
      exit
      ;;
    --macos)
      install_macos
      backup
      link_dotfiles
      zsh
      source ~/.zshrc
      exit
      ;;
    --ubuntu)
      install_ubuntu
      backup
      link_dotfiles
      zsh
      source ~/.zshrc
      exit
      ;;
    --backup)
      backup
      exit
      ;;
    --dotfiles)
      link_dotfiles
      exit
      ;;
  esac

  shift
done
