# dotfiles

Configuration files for my Linux systems

## Intro

![[^_^]][prompt-face] Hi!  
![[^_^]][prompt-face] Welcome to the davla's configuration files repository,
                      aka "dotfiles".  
![[^_^]][prompt-face] The configuration is used on three systems: my personal
                      laptop, running [sway](https://swaywm.org/) on
                      [Arch Linux](https://archlinux.org/); my
                      [Raspberry Pi](https://www.raspberrypi.com/),  
![     ][indent]      running headless
                      [Arch Linux ARM](https://archlinuxarm.org/); my work
                      laptop, running [i3](https://i3wm.org/) on
                      [Debian](https://www.debian.org/).  
![[^_^]][prompt-face] The system provisioning is handled in
                      [`bot.sh`](./bot.sh), that leverages
                      [dotdrop](https://github.com/deadc0de6/dotdrop) to copy
                      configuration files around on  
![     ][indent]      the filesystem.  
![[^_^]][prompt-face] Dotdrop is executed as a Python dependency via
                      [uv](https://docs.astral.sh/uv/). The Python version is
                      pinned by [asdf](https://asdf-vm.com/).  
![[ToT]][sad-face]    Some configuration files contain sensitive information,
                      especially for my work laptop configuration.  
![     ][indent]      They are encrypted in this repository via
                      [git-secret](https://sobolevn.me/git-secret/).

# setup
System initial setup

## Roadmap
- ACYLS update
- Ease log opening
- Fix STDERR usage in aestetics.sh::get_archive
- Bot relative paths
- Fix mako actions
- Fix bluez

[error-face]: docs/img/error-face.svg "Error face"
[indent]: docs/img/indent.svg "Indent"
[ok-face]: docs/img/ok-face.svg "OK face"
[prompt-face]: docs/img/prompt-face.svg "Prompt face"
[sad-face]: docs/img/sad-face.svg "Sad face"
