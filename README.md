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
                      [`bot.sh`](./bot.sh), which leverages
                      [dotdrop](https://github.com/deadc0de6/dotdrop) to copy
                      configuration files around on  
![     ][indent]      the filesystem.  
![[^_^]][prompt-face] Dotdrop is executed as a Python dependency via
                      [uv](https://docs.astral.sh/uv/). The Python version is
                      pinned by [devbox](https://www.jetify.com/devbox).  
![[ToT]][sad-face]    Some configuration files contain sensitive information,
                      especially for my work laptop configuration. They are  
![     ][indent]      encrypted in this repository via
                      [git-secret](https://sobolevn.me/git-secret/).  

## Dotdrop

[README](./dotfiles/README.md)

![[^_^]][prompt-face] [Dotdrop](https://github.com/deadc0de6/dotdrop)
                      constitutes the functioning core of this repository.
                      Immense gratitude to
                      [deadc0de6](https://github.com/deadc0de6) for creating
                      and  
![     ][indent]      maintaining such an amazingly useful tool!  
![[^_^]][prompt-face] The whole dotdrop setup is located at
                      [`dotfiles`](./dotfiles/). Dotdrop is so central to this
                      repository that it has its own  
![     ][indent]      documentation section in
                      [`dotfiles/README.md`](./dotfiles/README.md).  

## [`bot.sh`](./bot.sh)

![[^_^]][prompt-face] The [`bot.sh`](./bot.sh) script is where you will see
                      these faces!  
![[^_^]][prompt-face] The script is meant as the entry point for the whole
                      system provisioning. Therefore it is written in POSIX
                      shell  
![     ][indent]      and it assumes that only the basic tools are already
                      installed on the system. Or at least, that would be my  
![     ][indent]      goal. Anything else needed is installed by the script
                      itself, from the Python interpreter to dotdrop.  
![[^_^]][prompt-face] The core of the script consists in going through a series
                      of steps, asking before each whether to execute or  
![     ][indent]      skip it. Additionally, you can execute a specific step by
                      name, either by passing it on the command line, or by  
![     ][indent]      interactively entering it when prompted.  
![[>.<]][error-face]  There is no information on which steps should be run on
                      which host. I also get it wrong often.  
![[^_^]][prompt-face] Each step runs in a terminal alternate buffer (if
                      supported) for a cleaner output. The output is also
                      written to  
![     ][indent]      a log file that can be inspected after the step
                      execution. The log file is deleted before proceeding to
                      the next  
![     ][indent]      step.  
![[>.<]][error-face]  Reading the log file needs to happen in another terminal
                      for the time being. You also need to stay on the step  
![     ][indent]      you want to read the logs for in the terminal running the
                      bot script, otherwise the log file is deleted.  
![[^_^]][prompt-face] After executing each step, the bot will ask you if you
                      want to try to execute the step again, or proceed to the  
![     ][indent]      next step. This is meant as a form of debugging, as you
                      can edit the step code in case of errors and try again  
![     ][indent]      right away.  
![[>.<]][error-face]  There is an annoyingly large overlap between the bot
                      steps and dotdrop actions. The overall criterion to  
![     ][indent]      determine where the setup code should be placed is
                      "dotdrop actions contain code that is needed for the  
![     ][indent]      configuration files *not to crash*, while bot steps
                      contain code that is needed for the configuration files
                      to be  
![     ][indent]      *used*". This is admittedly not a very good and clean-cut
                      criterion, and likely means that I should just stick to  
![     ][indent]      one place for the setup code.  

## Desired improvements

![[°o°]][ok-face]     Make opening bot step log files more convenient. Possibly
                      via a dedicated answer after step execution.  
![[°o°]][ok-face]     Stop using LightDM.  
![[°o°]][ok-face]     Actually send myself a mail on `at` job errors.  
![[^_^]][prompt-face] Setup keyboard shortcuts for bluez.  
![[^_^]][prompt-face] Prevent `dotnet` crypto stuff from showing up in `$HOME`.  
![[^_^]][prompt-face] Allow logger colors with no tags.  
![[^_^]][prompt-face] Investigate more uses for jinja default.  
![[^_^]][prompt-face] Investigate uses of empty `dst:` instead of mktemp.  
![[>.<]][error-face]  Ensure systemd daemon-reload before enabling in pacman
                      hooks.  
![[>.<]][error-face]  Ensure that autorandr environemnt variable are loaded in
                      xsessionrc.  
![[>.<]][error-face]  Handle failure with pkgfile database update at Arch
                      startup.  
![[>.<]][error-face]  Automatically update ACYLS icons.  
![[>.<]][error-face]  Fix problems with mako actions.  
![[>.<]][error-face]  Update bot relative paths.  

[error-face]: docs/img/error-face.svg "Error face"
[indent]: docs/img/indent.svg "Indent"
[ok-face]: docs/img/ok-face.svg "OK face"
[prompt-face]: docs/img/prompt-face.svg "Prompt face"
[sad-face]: docs/img/sad-face.svg "Sad face"
