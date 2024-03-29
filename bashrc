#
# ~/.bashrc
#

# if not running interactively, don't do anything
# NOTE: .bashrc is only sourced when bash is run interactively so this seems redundant,
# but it turns out bash will still source .bashrc in a non-interactive remote shell (eg. when run via ssh)
# see the "remote shell daemon" section here for more info:
# https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html
# also here for a more detailed example:
# https://unix.stackexchange.com/a/257613
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

# start keychain
# turns out i actually do need this on doubleslap, otherwise using ssh is a pain in the ass lmao
# TODO: check the situation with this on cometpunch, not sure why i don't get pestered for a password on there...
if [[ $HOSTNAME == doubleslap ]]
then
    eval $(keychain -q --eval id_rsa)
fi

# load pyenv (but only on cometpunch)
if [[ $HOSTNAME == cometpunch ]]
then
    eval "$(pyenv init -)"
fi

# load direnv (has to go last, apparently)
eval "$(direnv hook bash)"
