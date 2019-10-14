#!/usr/bin/env bash

# Define the prompt string.
# Updated 2019-10-13.

# The default value is '\s-\v\$ '.

# - \! : the history number of this command
# - \# : the command number of this command
# - \$ : if the effective UID is 0, a #, otherwise a $
# - \@ : the current time in 12-hour am/pm format
# - \A : the current time in 24-hour HH:MM format
# - \D{format} : the format is passed to strftime(3)
# - \H : hostname
# - \T : the current time in 12-hour HH:MM:SS format
# - \V : the release of bash, version + patch level (e.g., 2.00.0)
# - \W : the basename of the current working directory, with $HOME as tilde
# - \[ : begin a sequence of non-printing characters
# - \\ : a backslash
# - \] : end a sequence of non-printing characters
# - \a : an ASCII bell character (07)
# - \d : the date in “Weekday Month Date” format (e.g., “Tue May 26”)
# - \e : an ASCII escape character (033)
# - \h : hostname up to the first '.'
# - \j : the number of jobs currently managed by the shell
# - \l : the basename of the shellâ€™s terminal device name
# - \n : newline
# - \nnn : the character corresponding to the octal number nnn
# - \r : carriage return
# - \s : shell name, the basename of '$0'
# - \t : the current time in 24-hour HH:MM:SS format
# - \u : the username of the current user
# - \v : the version of bash (e.g., 2.00)
# - \w : the current working directory, with $HOME abbreviated with a tilde

# Foreground colors (text)
# - 39 : default
# - 30 : black
# - 31 : red
# - 32 : green
# - 33 : yellow
# - 34 : blue
# - 35 : magenta
# - 36 : cyan
# - 37 : light gray
# - 90 : dark gray
# - 91 : light red
# - 92 : light green
# - 93 : light yellow
# - 94 : light blue
# - 95 : light magenta
# - 96 : light cyan
# - 97 : white

# See also:
# - https://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html
# - https://misc.flogisoft.com/bash/tip_colors_and_formatting

PS1="$(_koopa_prompt)"
export PS1
