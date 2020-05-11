{#@@
    This snippet adds system-wide environment variables defined in
    /etc/profile.d/env-vars.sh to shell other than POSIX. It is meant to be
    appended to shell-specific system-wide initialization files, such as
    /etc/zsh/zshenv on Debian system.
-@@#}

. /etc/profile.d/env-vars.sh
