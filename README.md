# dotfiles
My dot files!

## other config stuff:
- i had some issues with setting my right monitor as primary on cometpunch. couldn't get it working through xorg for the life of me (it swapped the positions instead), so i gave up and added this to /etc/lightdm/lightdm.conf:
```
display-setup-script=xrandr --output HDMI-0 --primary
```
