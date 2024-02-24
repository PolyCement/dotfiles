#!/usr/bin/env bash
#
# ~/.bash_profile
#

# NOTE: this only runs when bash is run as a login shell
# i'm pretty sure there's no weird caveats to this here (unlike with .bashrc,)

# append the given path to $PATH, but only if it exists
maybe_append_to_path() {
    [[ -d $1 ]] && export PATH=$PATH:$1
}

# add my scripts to path (if they exist)
maybe_append_to_path ~/bin
maybe_append_to_path ~/.local/bin
maybe_append_to_path ~/dotfiles/bin

# export go vars and add it to path if it's installed
GO_PATH="~/go"
if [[ -d $GO_PATH ]]
then
    export GOPATH=~/go
    export GO111MODULE=on
    export PATH=$PATH:$GOPATH/bin
fi

# add resolve to the path if it's installed (i'm still annoyed about this,)
maybe_append_to_path /opt/resolve/bin

# set up pyenv if it's installed (doing this last since it has an init step that probably relies on the path,)
# NOTE: pyenv specifically wants to go at the front of the path rather than at the end,
PYENV_PATH=~/.pyenv
if [[ -d $PYENV_PATH ]]
then
    export PYENV_ROOT=$PYENV_PATH
    export PATH=$PYENV_PATH/bin:$PATH
    eval "$(pyenv init --path)"
fi

# set visual
export VISUAL=nvim

# enable command history in iex
export ELIXIR_ERL_OPTIONS="-kernel shell_history enabled"

# source .bashrc if it exists (login shells won't source it by default even if they're interactive)
[[ -f ~/.bashrc ]] && . ~/.bashrc
