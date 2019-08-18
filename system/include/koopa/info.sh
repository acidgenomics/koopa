#!/usr/bin/env bash

# shellcheck source=/dev/null
source "${KOOPA_HOME}/shell/bash/include/header.sh"

# Show koopa installation information.
# Updated 2019-08-18.

shell="${KOOPA_SHELL} $(_koopa_${KOOPA_SHELL}_version)"

if _koopa_is_darwin
then
    os="$(_koopa_macos_version)"
else
    os="$(python -mplatform)"
fi

array=(
    "$(koopa --version)"
    "https://koopa.acidgenomics.com/"
    ""
    "## System information"
    "Koopa home: ${KOOPA_HOME}"
    "Shell: ${shell}"
    "OS: ${os}"
    "Terminal: ${TERM_PROGRAM} ${TERM_PROGRAM_VERSION}"
    ""
    "Run 'koopa check' to verify installation."
)

_koopa_info_box "${array[@]}"
