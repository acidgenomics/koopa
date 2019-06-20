#!/usr/bin/env bash

# Show koopa installation information (in a box).
# Modified 2019-06-12.

# shellcheck source=/dev/null
source "${KOOPA_DIR}/shell/bash/include/header.sh"

array=()
array+=("$(koopa --version)")
array+=("https://koopa.acidgenomics.com/")
array+=("")
array+=("## System information")
array+=("OS: $(python -mplatform)")
array+=("Current shell: ${KOOPA_SHELL}")
array+=("Default shell: ${SHELL}")
array+=("Install path: $KOOPA_DIR")
array+=("")
array+=("## Dependencies")
array+=("$(_koopa_locate bash Bash)")
array+=("$(_koopa_locate R)")
array+=("$(_koopa_locate python Python)")
array+=("")
array+=("Run 'koopa check' to verify installation.")

_koopa_info_box "${array[@]}"
