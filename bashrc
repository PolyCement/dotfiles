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

# for whatever reason nvm doesn't put itself in the path?
# i dont know the specifics but there's probably a good reason
if test -f "/usr/share/nvm/init-nvm.sh"; then
    . /usr/share/nvm/init-nvm.sh
fi

# print the wu tang logo
# i'll put somethin else here eventually (probably)

# this function centres the given string
function print_centred {
    columns=$(tput cols)
    while read -r line; do
        printf "%*s\n" $(( (${#line} + columns) / 2)) "$line"
    done <<< "$1"
}

# its the wu, comin thru
message=$'                             ,;ldo;     
    ;::;,,                ,:ldO000x:    
   ;dOOkxxdolc:;       ,:lxO0000000d;   
  ,oO000000000kc,     ,ck0000000000Oo,  
  ck0000000000d;  ;clc;,oO0000000000x;  
 ,o00000000000d;;lkO0Od;lO0000000000kc  
 ;d00000000000Oolx0000Oxk00000000000Oc  
 ;d0000000000000O0000000000000000000kc  
 ,d000000000000000000000000000000000k:  
  cO0000000000000000Oxdk000000000000d,  
  ,oO00000000000000Oxc,:x0000000000kc   
   ;oO0000000000000Okl, :x00000000Ol,   
    ,cxO0000000000000kc, ck000000kl,    
      ,cdkO00000000000kl;,o0000Ox:,     
        ,;:lodxkkkkkkxxo:,cO0Odc,       
              ,,,,,,,,,   ;ll;,         '

# print_centred "$message"

# start keychain (does this belong here???)
# commented out cos i never use it anymore
# eval $(keychain -q --eval id_rsa)
