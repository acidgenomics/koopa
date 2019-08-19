#!/usr/bin/env bash

# shellcheck source=/dev/null
source "${KOOPA_HOME}/shell/bash/include/header.sh"

# Show koopa installation information.
# Updated 2019-08-19.

shell="$(_koopa_shell)"
shell="${shell} $(_koopa_"${shell}"_version)"

if _koopa_is_darwin
then
    os="$(_koopa_macos_version)"
else
    os="$(python -mplatform)"
fi

# > term="Terminal: ${TERM_PROGRAM:-} ${TERM_PROGRAM_VERSION:-}"

array=(
    "$(koopa --version)"
    "https://koopa.acidgenomics.com/"
    ""
    "## System information"
    "Koopa home: $(_koopa_home)"
    "Shell: ${shell}"
    "OS: ${os}"
    ""
    "Run 'koopa check' to verify installation."
)

_koopa_info_box "${array[@]}"
