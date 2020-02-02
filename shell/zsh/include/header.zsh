#!/usr/bin/env zsh

# """
# Zsh shared header script.
# Updated 2020-02-02.
#
# See also:
# - https://scriptingosx.com/2019/06/moving-to-zsh-part-3-shell-options/
# """

# > setopt

setopt errexit
setopt nounset
setopt pipefail

# Requiring Zsh >= 5 for exported scripts.
major_version="$(echo "${ZSH_VERSION}" | cut -d '.' -f 1)"
if [[ ! "$major_version" -ge 5 ]]
then
    echo "Zsh >= 5 is required."
    exit 1
fi

KOOPA_ZSH_INC="$(cd "$(dirname "${(%):-%N}")" >/dev/null 2>&1 && pwd -P)"

# Source POSIX functions.
# shellcheck source=/dev/null
source "${KOOPA_ZSH_INC}/../../posix/include/functions.sh"

# Source ZSH functions.
# shellcheck source=/dev/null
# > source "${KOOPA_ZSH_INC}/functions.sh"

_koopa_help "$@"

# Require sudo permission to run 'sbin/' scripts.
if echo "$0" | grep -q "/sbin/"
then
    _koopa_assert_has_sudo
fi

unset -v KOOPA_ZSH_INC
