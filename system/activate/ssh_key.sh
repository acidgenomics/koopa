#!/bin/ssh
# shellcheck disable=SC2236

# Load an SSH key automatically, using SSH_KEY global variable.
# NOTE: SCP will fail unless this is interactive only.
# ssh-agent will prompt for password if there's one set.
# To change SSH key passphrase: ssh-keygen -p
if [ ! -z "$INTERACTIVE" ] && [ ! -z "$LINUX" ]
then
    # If the user hasn't requested a specific SSH key, look for the default.
    if [ -z "$SSH_KEY" ]
    then
        export SSH_KEY="${HOME}/.ssh/id_rsa"
    fi
    if [ -r "$SSH_KEY" ]; then
        # This step is necessary to start the ssh agent.
        eval "$(ssh-agent -s)"
        # Now we're ready to add the key.
        ssh-add "$SSH_KEY"
    fi
fi
