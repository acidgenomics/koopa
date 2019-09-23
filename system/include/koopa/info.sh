#!/usr/bin/env bash

# shellcheck source=/dev/null
source "${KOOPA_HOME}/shell/bash/include/header.sh"

# Show koopa installation information.
# Updated 2019-09-23.

shell="$KOOPA_SHELL"
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
    "Configuration"
    "-------------"
    "Home: $(_koopa_home)"
    "Config: $(_koopa_config_dir)"
    "Prefix: $(_koopa_build_prefix)"
    ""
)

# Show neofetch info, if installed.
if _koopa_is_installed neofetch
then
    mapfile -t nf < <( neofetch --stdout )
    array+=(
        "System information (neofetch)"
        "-----------------------------"
        "${nf[@]:2}"
    )
else
    array+=(
        "System information"
        "------------------"
        "OS: ${os}"
        "Shell: ${shell}"
        ""
    )
fi

array+=("Run 'koopa check' to verify installation.")

cat "${KOOPA_HOME}/system/include/koopa/ascii-turtle.txt"
_koopa_info_box "${array[@]}"

