#!/usr/bin/env bash

# """
# Bash shared header script.
# Updated 2020-02-13.
# """

# > set --help
# > shopt

# > set -o noglob       # -f
# > set -o xtrace       # -x
set -o errexit          # -e
set -o errtrace         # -E
set -o nounset          # -u
set -o pipefail

# Requiring Bash >= 4 for exported scripts.
# macOS ships with an ancient version of Bash, due to licensing.
major_version="$(echo "${BASH_VERSION}" | cut -d '.' -f 1)"
if [[ ! "$major_version" -ge 4 ]]
then
    echo "ERROR: Bash >= 4 is required."
    exit 1
fi
# Check that user's Bash has mapfile builtin defined.
# We use this a lot to handle arrays.
if [[ $(type -t mapfile) != "builtin" ]]
then
    echo "ERROR: Bash is missing 'mapfile' builtin."
    exit 1
fi

KOOPA_BASH_INC="$(cd "$(dirname "${BASH_SOURCE[0]}")" \
    >/dev/null 2>&1 && pwd -P)"

# Source POSIX functions.
# shellcheck source=/dev/null
source "${KOOPA_BASH_INC}/../../posix/include/functions.sh"

# Source Bash functions.
# shellcheck source=/dev/null
source "${KOOPA_BASH_INC}/functions.sh"

_koopa_help "$@"

# Require sudo permission to run 'sbin/' scripts.
if echo "$0" | grep -q "/sbin/"
then
    _koopa_assert_has_sudo
fi

unset -v KOOPA_BASH_INC
