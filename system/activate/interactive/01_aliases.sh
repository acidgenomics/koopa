# Quicker exit.
alias e="exit"

# Submit interactive queue.
alias i="submit_interactive"

# Listing files.
alias la="ls -a"
alias lF="ls -F"
alias ll="ls -AFGlh"

# Run emacs without window system.
alias emacs="emacs --no-window-system"

# Disable R prompt to save workspace.
# --no-environ
# --no-init
# --no-restore
# --no-save
# --vanilla
alias R="R --no-restore --no-save"

# Fake realpath support, if necessary.
if [[ -z $( command -v realpath 2>/dev/null ) ]]; then
    alias realpath="readlink -f"
fi
