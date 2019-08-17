#!/usr/bin/env bash

# shellcheck source=/dev/null
source "${KOOPA_HOME}/shell/bash/include/header.sh"

# Show koopa installation information (in a box).
# Updated 2019-06-22.

array=()
array+=("$(koopa --version)")
array+=("https://koopa.acidgenomics.com/")
array+=("")
array+=("## System information")
array+=("OS: $(python -mplatform)")
if _koopa_is_darwin
then
    array+=("    $(_koopa_macos_version)")
fi
array+=("Current shell: $(koopa shell)")
array+=("Default shell: ${SHELL}")
array+=("Terminal: ${TERM_PROGRAM} (${TERM_PROGRAM_VERSION})")
array+=("Install path: $(koopa home)")
array+=("")
array+=("## Dependencies")
array+=("$(_koopa_locate bash Bash)")
array+=("$(_koopa_locate R)")
array+=("$(_koopa_locate python Python)")
array+=("")
array+=("Run 'koopa check' to verify installation.")

_koopa_info_box "${array[@]}"
