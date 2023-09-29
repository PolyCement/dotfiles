# enable coloured ls output (was in .bashrc for some reason???)
alias ls='ls --color=auto'
# ls shorthands
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
# mounting devices
alias mntphone='go-mtpfs ~/mnt/phone &'
# use my extension of less
alias less='less2'
# force view to call nvim instead of vi/vim
alias view='nvim -R'
# make feh autoscale big images
alias feh='feh -.'
# more handy shortcuts
alias suspend='systemctl suspend'
# on god it is 2023 name your fucking executables properly
alias bookworm='com.github.babluboy.bookworm'
alias bespokesynth='BespokeSynth'
# locally installed game's
alias minecraft='~/games/minecraft/run.sh'
alias atlauncher='~/games/atlauncher/run.sh'
alias fallout='~/games/fallout/run.sh'
# :)
alias youtube-yownloader='yt-dlp'
alias yy='yt-dlp'
# spleeter needs a specific version of python and having to specify a model is tedious
alias spleeter2='PYENV_VERSION=3.8.10 spleeter separate -p spleeter:2stems-16kHz -o output'
alias spleeter5='PYENV_VERSION=3.8.10 spleeter separate -p spleeter:5stems-16kHz -o output'
# got demucs installed via pip so here's this
alias demucs='python -m demucs'
# i'm not adding this one to my path get outta here
alias resolve='/opt/resolve/bin/resolve'
