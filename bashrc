#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# set prompt appearance
PS1='\[\e[0;32m\]\u\[\e[m\]@\[\e[0;33m\]\h\[\e[m\] \W \[\e[0;31m\]❤\[\e[m\] '
INPUTRC=~/.inputrc

# make command history bigger
HISTSIZE=1000
HISTFILESIZE=1000

# colourise man pages
man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;07m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[04;32m' \
    command man "$@"
}

# load aliases
. ~/.bash_aliases

# enable more autocompletion
. /usr/share/bash-completion/bash_completion

# fzf stuff
. /usr/share/fzf/key-bindings.bash
. /usr/share/fzf/completion.bash

# for whatever reason nvm doesn't put itself in the path?
# i dont know the specifics but there's probably a good reason
if test -f "/usr/share/nvm/init-nvm.sh"; then
    . /usr/share/nvm/init-nvm.sh
fi

# start keychain (does this belong here???)
# commented out cos i never use it anymore
# eval $(keychain -q --eval id_rsa)

# load pyenv (but only on cometpunch)
if [[ $HOSTNAME == cometpunch ]]
then
    eval "$(pyenv init -)"
fi

# load direnv (has to go last, apparently)
eval "$(direnv hook bash)"
