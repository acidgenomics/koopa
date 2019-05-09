#!/bin/sh
# shellcheck disable=SC2236

# Check that bash version is supported.
# Always requiring bash, even if it's not the current shell.
#
# See also:
# - https://stackoverflow.com/questions/16989598
# - https://stackoverflow.com/questions/4023830
#
# Alternatively, can use `$BASH_VERSINFO` to get the major version.

bash_version=$( \
    bash --version | \
    head -n1 | \
    cut -d " " -f 4 | \
    cut -d "-" -f 1  | \
    cut -d "(" -f 1 \
)

bash_major_version="$(printf '%s' "$bash_version" | cut -c 1)"

if [ "$bash_major_version" -lt 4 ]
then
    echo "Bash version: $bash_version"
    echo "Koopa requires Bash >= v4 to be installed."
    echo ""
    echo "Running macOS?"
    echo "Apple refuses to include a modern version due to the license."
    echo ""
    echo "Here's how to upgrade it using Homebrew:"
    echo "1. Install Homebrew."
    echo "   https://brew.sh/"
    echo "2. Install Bash."
    echo "   brew install bash"
    echo "3. Update list of acceptable shells."
    echo "   Requires sudo."
    echo "   Add /usr/local/bin/bash to /etc/shells."
    echo "4. Update default shell."
    echo "   chsh -s /usr/local/bin/bash $USER"
    echo "5. Reload the shell and check Bash version."
    echo "   bash --version"
    return 1
fi

unset -v bash_version

