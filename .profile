# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

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

PATH=/bin:/sbin
PATH=$PATH:/usr/bin:/usr/sbin
PATH=$PATH:/usr/local/bin:/usr/local/sbin
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$PATH:$HOME/bin"
fi
export PATH

export LANGUAGE="en_US:en"
export LC_MESSAGES="en_US.UTF-8"
export LANG="sv_SE.UTF-8"

export http_proxy="http://wwwproxy.se.axis.se:3128/"
