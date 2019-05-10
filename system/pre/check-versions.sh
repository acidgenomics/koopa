#!/bin/sh
# shellcheck disable=SC2236

# Check for supported dependency versions.



# Bash                                                                      {{{1
# ==============================================================================

# Bash is always required, even if it's not the current shell.
#
# See also:
# - https://stackoverflow.com/questions/16989598
# - https://stackoverflow.com/questions/4023830
#
# Alternatively, can use `$BASH_VERSINFO` to get the major version.

version=$( \
    bash --version | \
    head -n1 | \
    cut -d " " -f 4 | \
    cut -d "-" -f 1  | \
    cut -d "(" -f 1 \
)

major_version="$(printf '%s' "$version" | cut -c 1)"

if [ "$major_version" -lt 4 ]
then
    echo "Bash version: ${version}"
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
    echo "   chsh -s /usr/local/bin/bash ${USER}"
    echo "5. Reload the shell and check Bash version."
    echo "   bash --version"
    return 1
fi

unset -v major_version version



# Python                                                                    {{{1
# ==============================================================================

# Note that we're checking for supported Python version in the post-flight
# checks instead, allowing the user to use either conda or virtualenv.

command -v python >/dev/null 2>&1 || {
    echo >&2 "koopa requires Python."
    return 1
}



# turn on folds
# vim: fdm=marker
