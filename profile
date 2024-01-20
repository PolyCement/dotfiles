#!/bin/bash

# stuff for go...
export GOPATH=~/go
export GO111MODULE=on
# stuff that lets me use pyenv
export PYENV_ROOT="$HOME/.pyenv"
# pyenv specifies itself as going *before* the rest of the path, which is... odd? but ok
export PATH=$PYENV_ROOT/bin:$PATH:~/bin:~/.local/bin:~/dotfiles/bin:~/.gem/ruby/2.4.0/bin:$GOPATH/bin:/opt/resolve/bin/resolve
# i guess its best to init pyenv after setting path,
eval "$(pyenv init --path)"
export VISUAL=vim
# enable command history in iex
export ELIXIR_ERL_OPTIONS="-kernel shell_history enabled"
# dualshock 2 mapping, taken from https://github.com/gabomdq/SDL_GameControllerDB
# some games will use this if it's defined, but fall back to autoconfig if it's missing
# unity doesn't seem to have an autoconfig though, so i'm defining it manually
# (the name should probably be "Twin USB Joystick" rather than "Twin USB PS2 Adapter"
# but it doesn't seem to matter)
# commenting this out to see if it's what's fucking up my controller in steam :)
#export SDL_GAMECONTROLLERCONFIG="03000000100800000100000010010000,Twin USB PS2 Adapter,a:b2,b:b1,back:b8,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,leftshoulder:b6,leftstick:b10,lefttrigger:b4,leftx:a0,lefty:a1,rightshoulder:b7,rightstick:b11,righttrigger:b5,rightx:a3,righty:a2,start:b9,x:b3,y:b0,platform:Linux,"
# TODO: figure out if these should be in .xprofile since they're meaningless without x running
# overlay scrollbars can fuck off
export GTK_OVERLAY_SCROLLING=0
# set this so qt5 can be configured using qt5ct, since im not using a de qt5 can pull a theme from
export QT_QPA_PLATFORMTHEME="qt5ct"
