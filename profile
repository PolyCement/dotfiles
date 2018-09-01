#!/bin/bash

# self explanatory
export PATH=$PATH:~/bin:~/dotfiles/bin:~/.gem/ruby/2.4.0/bin:~/go/bin
export VISUAL=vim
# dualshock 2 mapping, taken from https://github.com/gabomdq/SDL_GameControllerDB
# some games will use this if it's defined, but fall back to autoconfig if it's missing
# unity doesn't seem to have an autoconfig though, so i'm defining it manually
# (the name should probably be "Twin USB Joystick" rather than "Twin USB PS2 Adapter"
# but it doesn't seem to matter)
export SDL_GAMECONTROLLERCONFIG="03000000100800000100000010010000,Twin USB PS2 Adapter,a:b2,b:b1,back:b8,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,leftshoulder:b6,leftstick:b10,lefttrigger:b4,leftx:a0,lefty:a1,rightshoulder:b7,rightstick:b11,righttrigger:b5,rightx:a3,righty:a2,start:b9,x:b3,y:b0,platform:Linux,"
# overlay scrollbars can fuck off
export GTK_OVERLAY_SCROLLING=0
