
script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
user_path="$( cd "$( dirname "~" )" && pwd )"
uninstall_sh=$script_path/uninstall.sh

[[ -f ~/.bash_profile_previous ]] && $script_path/uninstall.sh

###############################################################################
## BIN
ln -si $script_path/bin ~/.bin
echo "rm -f ~/.bin" >> $script_path/uninstall.sh

###############################################################################
## BASH PROFILE
dfbash=$script_path/bash

echo "rm -f ~/.bash_profile" >> $uninstall_sh

if [[ -a ~/.bash_profile ]]; then
	mv ~/.bash_profile ~/.bash_profile_previous
	echo "mv ~/.bash_profile_previous ~/.bash_profile" >> $uninstall_sh
fi

ln -s $dfbash/config ~/.bash_config
echo "rm -f ~/.bash_config" >> $uninstall_sh

ln -s $dfbash/bash_profile ~/.bash_profile

source $user_path/.bash_profile
echo "source $user_path/.bash_profile" >> $uninstall_sh

###############################################################################
## GIT
ln -si $script_path/git/gitconfig ~/.gitconfig
echo "rm -f ~/.gitconfig" >> $script_path/uninstall.sh

###############################################################################
## VIM
ln -si $script_path/vim ~/.vim
echo "rm -f ~/.vim" >> $script_path/uninstall.sh
