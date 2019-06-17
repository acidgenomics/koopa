#!/bin/sh
# shellcheck disable=SC2236

# Load an SSH key automatically, using SSH_KEY global variable.
# Modified 2019-06-17.

# NOTE: SCP will fail unless this is interactive only.
# ssh-agent will prompt for password if there's one set.

# To change SSH key passphrase:
# > ssh-keygen -p

[ ! -z "${INTERACTIVE:-}" ] && [ ! -z "${LINUX:-}" ] || return 0

# If the user hasn't requested a specific SSH key, look for the default.
ssh_key="${SSH_KEY:-${HOME}/.ssh/id_rsa}"
[ -r "$ssh_key" ] || return 0

# This step is necessary to start the ssh agent.
eval "$(ssh-agent -s)"

# Now we're ready to add the key.
ssh-add "$ssh_key"

unset -v ssh_key
