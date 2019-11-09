#!/usr/bin/env bash
set -Eeu -o pipefail

# Bash shared header script.
# Updated 2019-11-09.

KOOPA_BASH_INC="$(cd "$(dirname "${BASH_SOURCE[0]}")" \
    >/dev/null 2>&1 && pwd -P)"

# Source POSIX functions.
# shellcheck source=/dev/null
source "${KOOPA_BASH_INC}/../../posix/include/functions.sh"

# Source Bash functions.
# shellcheck source=/dev/null
source "${KOOPA_BASH_INC}/functions.sh"
_acid_help "$@"

# Require sudo permission to run 'sbin/' scripts.
if echo "$0" | grep -q "/sbin/"
then
    _acid_assert_has_sudo
fi

unset -v KOOPA_BASH_INC
