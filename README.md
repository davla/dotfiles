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
![[ToY]][sad-face]    Some configuration files contain sensitive information,
                      especially for my work laptop configuration.  
![     ][indent]      They are encrypted in this repository via
                      [git-secret](https://sobolevn.me/git-secret/).

## Dotdrop

[README](./dotfiles/README.md)

![[^_^]][prompt-face] [Dotdrop](https://github.com/deadc0de6/dotdrop)
                      constitutes the functioning core of this repository.
                      Immense gratitude to
                      [deadc0de6](https://github.com/deadc0de6) for  
![     ][indent]      creating and maintaining such an amazingly useful tool!  
![[^_^]][prompt-face] The whole dotdrop setup is located at
                      [`dotfiles`](./dotfiles/). Dotdrop is so central to this
                      repository that it has  
![     ][indent]      its own documentation section in
                      [`dotfiles/README.md`](./dotfiles/README.md).  

## [`bot.sh`](./bot.sh)

![[^_^]][prompt-face] The [`bot.sh`](./bot.sh) script is where you will see
                      these faces!  
![[^_^]][prompt-face] The script is meant as the entry point for the whole
                      system provisioning. Therefore it is written in  
![     ][indent]      POSIX shell and it assumes that only the basic tools are
                      already installed on the system. Or at least,  
![     ][indent]      that would be my goal. Anything else needed is installed
                      by the script itself, from the Python  
![     ][indent]      interpreter to dotdrop.  
![[^_^]][prompt-face] The core of the script consists in going through a series
                      of steps, asking before each whether to  
![     ][indent]      execute or skip it. Additionally, you can execute a
                      specific step by name, either by passing it on the  
![     ][indent]      command line, or by interactively entering it when
                      prompted.  
![[>.<]][error-face]  There is no information on which steps should be run on
                      which host. I also get it wrong often.  
![[^_^]][prompt-face] Each step runs in a terminal alternate buffer (if
                      supported) for a cleaner output. The output is also  
![     ][indent]      written to a log file that can be inspected after the
                      step execution. The log file is deleted before  
![     ][indent]      proceeding to the next step.  
![[>.<]][error-face]  Reading the log file needs to happen in another terminal
                      for the time being. You also need to stay on  
![     ][indent]      the step you want to read the logs for in the terminal
                      running the bot script, otherwise the log file  
![     ][indent]      is deleted.  
![[^_^]][prompt-face] After executing each step, the bot will ask you if you
                      want to try to execute the step again, or  
![     ][indent]      proceed to the next step. This is meant as a form of
                      debugging, as you can edit the step code in case  
![     ][indent]      of errors and try again right away.  
![[>.<]][error-face]  There is an annoyingly large overlap between the bot
                      steps and dotdrop actions. The overall criterion  
![     ][indent]      to determine where the setup code should be placed is
                      "dotdrop actions contain code that is needed for  
![     ][indent]      the configuration files *not to crash*, while bot steps
                      contain code that is needed for the configuration  
![     ][indent]      files to be *used*". This is admittedly not a very good
                      and clean-cut criterion, and likely means that I  
![     ][indent]      should just stick to one place for the setup code.  


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
