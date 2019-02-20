#!/bin/sh
# shellcheck disable=SC2236

# Check that bash version is supported.
# Always requiring bash, even if it's not the current shell.
#
# See also:
# - https://stackoverflow.com/questions/16989598
# - https://stackoverflow.com/questions/4023830
#
# SC2128: Expanding an array without an index only gives the first element.
# shellcheck disable=SC2128
if [ -z "$BASH_VERSINFO" ]
then
    bash_version=$(bash --version | head -n1 | cut -f 4 -d " " | cut -d "-" -f 1  | cut -d "(" -f 1)
else
    # SC2039: In POSIX sh, array references are undefined.
    # shellcheck disable=SC2039
    bash_version="${BASH_VERSINFO[0]}"
fi
# SC2039: In POSIX sh, string indexing is undefined.
# Bash alternate: "${bash_version:0:1}"
# SC2071: < is for string comparisons. Use -lt instead.
bash_version="$(printf '%s' "$bash_version" | cut -c1)"
if [ "$bash_version" -lt 4 ]
then
    echo "bash version: $bash_version"
    echo "koopa requires bash >= v4 to be installed."
    echo ""
    echo "Running macOS?"
    echo "Apple refuses to include a modern version due to the license."
    echo ""
    echo "Here's how to upgrade it using Homebrew:"
    echo "1. Install Homebrew."
    echo "   https://brew.sh/"
    echo "2. Install bash."
    echo "   brew install bash"
    echo "3. Update list of acceptable shells."
    echo "   Requires sudo."
    echo "   Add /usr/local/bin/bash to /etc/shells."
    echo "4. Update default shell."
    echo "   chsh -s /usr/local/bin/bash $USER"
    echo "5. Reload the shell and check bash version."
    echo "   bash --version"
    exit 1
fi
unset -v bash_version

