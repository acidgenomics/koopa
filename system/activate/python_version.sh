#!/bin/ssh

# Check python (any version).
# Consider requiring >= 3 in a future update.

if ! quiet_which python
then
    echo "koopa requires python."
    return 1
fi
