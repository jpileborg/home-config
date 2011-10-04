# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# [ -f /etc/profile ] && . /etc/profile

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# PATH=/bin:/sbin
# PATH=$PATH:/usr/bin:/usr/sbin
# PATH=$PATH:/usr/local/bin:/usr/local/sbin
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$PATH:$HOME/bin"
fi
PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin
export PATH

export LANGUAGE="en_US:en"
export LC_MESSAGES="en_US.UTF-8"
export LANG="sv_SE.UTF-8"

if [ -f ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs ]; then
    . ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs
    export XDG_DESKTOP_DIR XDG_DOWNLOAD_DIR XDG_TEMPLATES_DIR XDG_PUBLICSHARE_DIR XDG_DOCUMENTS_DIR XDG_MUSIC_DIR XDG_PICTURES_DIR XDG_VIDEOS_DIR
fi
