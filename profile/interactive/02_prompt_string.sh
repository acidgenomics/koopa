# Customize the prompt string
# \!: the history number of this command
# \#: the command number of this command
# \H: hostname
# \W: working directory basename
# \h: hostname up to the first `.`
# \n: newline
# \r: carriage return
# \s: shell name, the basename of `$0`
# \u: username
# \w: working directory
user="\u@\h"
history="[\!; \#]"
wd="\w"
prompt="\$"

# Enable colors
if [[ $TERM = "xterm-256color" ]]; then
    user="\[\033[01;32m\]${user}\[\033[00m\]"
    wd="\[\033[01;34m\]${wd}\[\033[00m\]"
fi

export PS1="${user} ${history}\n${wd}\n${prompt} "
unset -v user wd

# Trim the number of directories
# Supported in bash 4
# Note that macOS is stuck on bash 3 due to GPL license, so this won't work
export PROMPT_DIRTRIM=3
