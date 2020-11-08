# Installation

Installing dotdrop [as a submodule](#as-a-submodule) is the recommended way.

If you want to keep your python environment clean, use the virtualenv installation instructions
(see [As a submodule in a virtualenv](#as-a-submodule-in-a-virtualenv) and
[Pypi package in a virtualenv](#pypi-package-in-a-virtualenv)).
In that case, the virtualenv environment might need to be loaded before any attempt to use dotdrop.

## As a submodule

The following will create a git repository for your dotfiles and
keep dotdrop as a submodule:
```bash
## create the repository
$ mkdir dotfiles; cd dotfiles
$ git init

## install dotdrop as a submodule
$ git submodule add https://github.com/deadc0de6/dotdrop.git
$ pip3 install --user -r dotdrop/requirements.txt
$ ./dotdrop/bootstrap.sh

## use dotdrop
$ ./dotdrop.sh --help
```

For MacOS users, make sure to install `realpath` through homebrew
(part of *coreutils*).

Using this solution will need you to work with dotdrop by
using the generated script `dotdrop.sh` at the root
of your dotfiles repository.

To ease the use of dotdrop, it is recommended to add an alias to it in your
shell with the config file path, for example
```
alias dotdrop=<absolute-path-to-dotdrop.sh> --cfg=<path-to-your-config.yaml>'
```

## As a submodule in a virtualenv

To install in a [virtualenv](https://virtualenv.pypa.io):
```bash
## create the repository
$ mkdir dotfiles; cd dotfiles
$ git init

## install dotdrop as a submodule
$ git submodule add https://github.com/deadc0de6/dotdrop.git
$ virtualenv -p python3 env
$ echo 'env' > .gitignore
$ source env/bin/activate
$ pip install -r dotdrop/requirements.txt
$ ./dotdrop/bootstrap.sh

## use dotdrop
$ ./dotdrop.sh --help
```

When using a virtualenv, make sure to source the environment before using dotdrop
```bash
$ source env/bin/activate
$ ./dotdrop.sh --help
```

Then follow the instructions under [As a submodule](#as-a-submodule).

## Pypi package

Install dotdrop
```bash
$ pip3 install dotdrop --user
```

and then [setup your repository](repository-setup.md).

## Pypi package in a virtualenv

Install dotdrop in a virtualenv from pypi
```bash
$ virtualenv -p python3 env
$ source env/bin/activate
$ pip install dotdrop
```

When using a virtualenv, make sure to source the environment
before using dotdrop:
```bash
$ source env/bin/activate
$ dotdrop --help
```

Then follow the instructions under [Pypi package](#pypi-package).

## Aur packages

Dotdrop is available on aur:

* stable: <https://aur.archlinux.org/packages/dotdrop/>
* git version: <https://aur.archlinux.org/packages/dotdrop-git/>

Then follow the [doc to setup your repository](repository-setup.md).

## Snap package

Dotdrop is available as a snap package: <https://snapcraft.io/dotdrop>

Install it with
```bash
snap install dotdrop
```

Then follow the [doc to setup your repository](repository-setup.md).

## Dependencies

Beside the python dependencies defined in [requirements.txt](https://github.com/deadc0de6/dotdrop/blob/master/requirements.txt),
dotdrop depends on following tools:

* `file`
* `diff`
* `mkdir`
* `git` (for the entry point script [dotdrop.sh](https://github.com/deadc0de6/dotdrop/blob/master/dotdrop.sh))
* `readlink` or `realpath` (for the entry point script [dotdrop.sh](https://github.com/deadc0de6/dotdrop/blob/master/dotdrop.sh))

For MacOS users, make sure to install `realpath` (part of `coreutils`) through [homebrew](https://brew.sh/).

## Update dotdrop

If using dotdrop as a submodule, one can control if dotdrop
is auto-updated through the [dotdrop.sh](https://github.com/deadc0de6/dotdrop/blob/master/dotdrop.sh)
script by defining the environment variable `DOTDROP_AUTOUPDATE=yes`.
If undefined, `DOTDROP_AUTOUPDATE` will take the value `yes`.

If used as a submodule, update it with
```bash
$ git submodule update --init --recursive
$ git submodule update --remote dotdrop
```

You will then need to commit the changes with
```bash
$ git add dotdrop
$ git commit -m 'update dotdrop'
$ git push
```

Or if installed through pypi:
```bash
$ pip3 install dotdrop --upgrade --user
```

## Shell completion

Completion scripts exist for `bash`, `zsh` and `fish`,
see [the related doc](https://github.com/deadc0de6/dotdrop/blob/master/completion/README.md).

