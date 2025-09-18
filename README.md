# dotfiles
my dot files!

## installation
just run `install` and that should link everything into the right places

### dependencies
- awesome theme:
    required:
    - xorg
    - vicious
    - ttf-material-symbols-variable-git

    optional:
    - maim (for screenshots)
    - pulse/pipewire-pulse, pavucontrol (for volume control)
    - playerctl (for additional media key functionality)

- xorg:
    optional:
    - fcitx5 (ime)
    - xcompmgr (compositor)
    - unclutter (for hiding the mouse when stationary)
    - xiccd (for managing colour profiles)
    - xsettingsd (for hidpi scaling in gtk4 apps)

- alacritty:
    required:
    - ttf-ricty-nerd

- nvim:
    required:
    - curl (for installing vim-plug) (maybe also for actually using vim-plug?)
    - xclip (for yanking to clipboard)

- bash:
    optional:
    - bash-completion (for better autocomplete, automatically sourced by arch)
    - fzf (for fuzzy search)
    - nvm (for node version management)
    - keychain (for making ssh less of a pain to use)
    - pyenv (for python version management - at least for now...)
    - direnv (for per-directory environment config)

- fontconfig:
    optional:
    - noto-fonts/noto-fonts-cjk (it kinda doesn't do anything if u dont have these)

- other scripts:
    check scripts in `dotfiles/bin` for per-script reqs

### notes
- nvim will complain about a missing colour scheme the first time u boot it up. thats cos it hasn't been generated yet! run `:PlugInstall` to generate it

## other config stuff:
- i had some issues with setting my right monitor as primary on cometpunch. couldn't get it working through xorg for the life of me (it swapped the positions instead), so i gave up and added this to /etc/lightdm/lightdm.conf:

    ```
    display-setup-script=xrandr --output HDMI-0 --primary
    ```

- fcitx overrides xkb settings by default, which breaks caps lock being bound to zenkaku/hankaku, so i had to switch it off ("addons" → "xcb" → "allow overriding system xkb settings")

- the awesomewm theme is set up to use whatever file is at `~/dotfiles/awesome/themes/default/background.png` as the desktop wallpaper. just symlink the file (or copy it? i guess?) there and it'll work

- firepunch has a hidpi screen and firefox looks too damn big on it even with the gtk3 config shrinking the font. for now i've fixed it by going into `about:config` and setting `browser.compactmode.show` to `true`, then enabling compact mode in the toolbar customisation screen
