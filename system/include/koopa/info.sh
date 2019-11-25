#!/usr/bin/env bash
set -Eeu -o pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
# shellcheck source=/dev/null
source "${script_dir}/../../../shell/bash/include/header.sh"

array=(
    "$(koopa --version)"
    "https://koopa.acidgenomics.com/"
    ""
    "Configuration"
    "-------------"
    "Koopa prefix: $(_koopa_prefix)"
    "Config prefix: $(_koopa_config_prefix)"
    "App prefix: $(_koopa_app_prefix)"
    "Make prefix: $(_koopa_make_prefix)"
    ""
)

if _koopa_is_linux
then
    array+=("Cellar prefix: $(_koopa_cellar_prefix)")
fi

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
        if _koopa_is_installed python
        then
            os="$(python -mplatform)"
        else
            os="$(uname --all)"
        fi
    fi
    shell_name="$KOOPA_SHELL"
    shell_version="$(_koopa_current_version "${shell_name}")"
    shell="${shell_name} ${shell_version}"
    unset -v shell_name shell_version
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

cat "${KOOPA_PREFIX}/system/include/koopa/ascii-turtle.txt"
_koopa_info_box "${array[@]}"
