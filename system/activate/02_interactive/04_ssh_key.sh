# Load an SSH key automatically.
# SCP will fail unless this is interactive only.
# Only applies when `$SSH_KEY` is set in environment.
if [[ -n ${SSH_KEY+x} ]]; then
    # Check that path is valid.
    if [[ ! -f "$SSH_KEY" ]]; then
        printf "SSH key does not exist at:\n${SSH_KEY}\n"
    fi
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY"
fi
