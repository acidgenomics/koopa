# Load an SSH key automatically.
# SCP will fail unless this is interactive only.
# Only applies when `$SSH_KEY` is set in environment.
if [[ -f "$SSH_KEY" ]]; then
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY"
fi
