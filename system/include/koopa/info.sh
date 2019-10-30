#!/usr/bin/env bash

# shellcheck source=/dev/null
source "${KOOPA_HOME}/shell/bash/include/header.sh"

# Show koopa installation information.
# Updated 2019-10-28.

shell="$KOOPA_SHELL"
shell="${shell} $(_koopa_"${shell}"_version)"

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
    # Using process substitution here.
    mapfile -t nf < <(neofetch --stdout)
    array+=(
        "System information (neofetch)"
        "-----------------------------"
        "${nf[@]:2}"
    )
else
    if _koopa_is_darwin
    then
        os="$( \
            printf "%s %s (%s)\n" \
                "$(sw_vers -productName)" \
                "$(sw_vers -productVersion)" \
                "$(sw_vers -buildVersion)" \
        )"
    else
        os="$(python -mplatform)"
    fi
    # > term="Terminal: ${TERM_PROGRAM:-} ${TERM_PROGRAM_VERSION:-}"
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
