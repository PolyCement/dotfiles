# enable coloured ls output (was in .bashrc for some reason???)
alias ls='ls --color=auto'
# ls shorthands
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
# mounting devices
alias mntphone='go-mtpfs ~/mnt/phone &'
# make livestreamer use mpv
alias livestreamer='livestreamer -p mpv'
# use my extension of less
alias less='less2'
# force view to call vim instead of vi
alias view='vim -R'
# make feh autoscale big images
alias feh='feh -.'
# more handy shortcuts
alias suspend='systemctl suspend'
# ughhhhhhh
alias pcsx2='PCSX2'
alias bookworm='com.github.babluboy.bookworm'
# locally installed game's
alias minecraft='~/games/minecraft/run.sh'
alias atlauncher='~/games/atlauncher/run.sh'
alias fallout='~/games/fallout/run.sh'
# :)
alias youtube-yownloader='youtube-dl'
alias yy='youtube-dl'
# spleeter needs a specific version of python and having to specify a model is tedious
alias spleeter2='PYENV_VERSION=3.8.10 spleeter separate -p spleeter:2stems-16kHz -o output'
alias spleeter5='PYENV_VERSION=3.8.10 spleeter separate -p spleeter:5stems-16kHz -o output'
