#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#PS1='[\u@\h \W]\$ '
PS1='\[\e[0;32m\]\u\[\e[m\]@\[\e[0;33m\]\h\[\e[m\] \W \[\e[0;31m\]❤\[\e[m\] '
INPUTRC=~/.inputrc

#load aliases
. ~/.bash_aliases

#enable more autocompletion
. /usr/share/bash-completion/bash_completion

#start keychain (does this belong here???)
eval $(keychain -q --eval id_rsa)
