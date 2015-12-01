#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
#PS1='[\u@\h \W]\$ '
PS1='\[\e[0;32m\]\u\[\e[m\]@\[\e[0;33m\]\h\[\e[m\] \W \[\e[0;31m\]❤\[\e[m\] '

#load aliases
. ~/.bash_aliases

#enable more autocompletion
. /usr/share/bash-completion/bash_completion

#ssh-agent is started with openbox, so we just load the details
if [[ "$SSH_AGENT_PID" == "" ]]; then
    eval `< ~/.ssh-agent` > /dev/null
fi
#temporarily alias ssh to ssh-add, then unalias again afterwards
ssh-add -l > /dev/null || alias ssh='ssh-add -l > /dev/null || ssh-add && unalias ssh; ssh'
