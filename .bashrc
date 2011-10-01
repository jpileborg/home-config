# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

function prompt_error_code() {
    ec="$?";
    if [ "$ec" != "0" ]; then    
        echo -n "[$ec]";
    fi;
}

if [ "$color_prompt" = yes ]; then
    # PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    PS1='\[\033[1m\]$(prompt_error_code)\[\033[0m\]${debian_chroot:+($debian_chroot)}[\[\033[01;34m\]\w\[\033[0m\]]\$ '
else
    # PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    PS1='$(prompt_error_code)${debian_chroot:+($debian_chroot)}[\w\]\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Do not expand ~
_expand()
{
    return 0;
}
__expand_tilde_by_ref()
{
    return 0
}

export LESSCHARSET="utf-8"

# Axis-specific configuration

export CVS_RSH=ssh
# export CVSROOT=":ext:dev-cvs.se.axis.com:/usr/local/cvs/linux"
export AXIS_DEVELOPER=y
export EDITOR=nano
export GIT_EDITOR=nano

#[ -f ~/products/camera/P7214/init_env ] && . ~/products/camera/P7214/init_env

function chp() {
    [ -d ~/products/$1 ] || (echo "No such project: $1"; return 1)
    cd ~/products/$1 || return 1

    # TODO: Clean up the PATH (in a bash-compatible way, not zsh'ish like this
    #newpath=()
    #for p in $path; do
    #  (  echo $p | grep -q $1 ) || newpath=($newpath $p)
    #done
    #export PATH=${(j.:.)newpath}

    export AXIS_TOP_DIR=~/products/$1
    [ -f ./init_env ] && source ./init_env
    export PATH=$PATH:$AXIS_TOP_DIR/build_env/bin
}

complete -W "`find $HOME/products/*/* -maxdepth 0 -type d | cut -d '/' -f 5-6`" chp

export LESSOPEN="| /usr/bin/lesspipe %s";
export LESSCLOSE="/usr/bin/lesspipe %s %s";
