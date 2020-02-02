#!/usr/bin/env bash
set -Eeu -o pipefail

# """
# Bash shared header script.
# Updated 2020-02-02.
# """

# Requiring Bash >= 5 for exported scripts.
major_version="$(echo "${BASH_VERSION}" | cut -d '.' -f 1)"
if [ ! "$major_version" -ge 5 ]
then
    echo "Bash >= 5 is required."
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
