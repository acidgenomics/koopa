#!/usr/bin/env bash

# Make bash stricter by default using set built-in.
#
# See also:
# - https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
# - https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
# - http://redsymbol.net/articles/unofficial-bash-strict-mode/

# NOTE: Do not attempt to use this in `bash_profile` for a remote SSH server,
# as unbound variables will cause the login to fail and you can get locked out.
# Only attempt to ever enable this mode on a local machine, where you can
# disable strict mode easily.

# For scripts, this one-liner can be placed under the shebang line:
# set -Eeuo pipefail

# Exit immediately when a command fails.
# NOTE: This will break RStudio terminal.
set -e

# Catch ERR traps properly, which won't fire in certain scenarios for `-e` flag.
set -E

# Treat unset variables as an error and exit immediately.
set -u

# Alternatively, can use:
# shopt -s failglob

# Print each command before executing. This command is great for scripts but too
# noisy when added to bash_profile, and is not generally recommended here.
set -x

# The bash shell normally only looks at the exit code of the last command of a
# pipeline. This behavior is not ideal as it causes the `-e` option to only be
# able to act on the exit code of a pipeline's last command. This is where
# `-o pipefail` comes in. This particular option sets the exit code of a
# pipeline to that of the rightmost command to exit with a non-zero status, or
# to zero if all commands of the pipeline exit successfully.
set -o pipefail

# Bash v4 checks for these unbound variables.
# EMACS=0
# INSIDE_EMACS=0
