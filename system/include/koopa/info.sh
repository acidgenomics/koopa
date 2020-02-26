#!/usr/bin/env bash

# Get the latest commit.
koopa_prefix="$(_koopa_prefix)"

version="$(_koopa_version)"
date="$(_koopa_variable "koopa-date")"
commit="$( \
    _koopa_cd "$koopa_prefix"; \
    _koopa_git_last_commit_local \
)"
url="$(_koopa_variable "koopa-url")"
dev_url="$(_koopa_variable "koopa-dev-url")"

array=(
    "koopa ${version} (${date})"
    "Commit: ${commit}"
    "URL: ${url}"
    "GitHub URL: ${dev_url}"
    ""
    "Configuration"
    "-------------"
    "Koopa Prefix: ${koopa_prefix}"
    "Config Prefix: $(_koopa_config_prefix)"
    "App Prefix: $(_koopa_app_prefix)"
    "Make Prefix: $(_koopa_make_prefix)"
)

if _koopa_is_linux
then
    array+=("Cellar Prefix: $(_koopa_cellar_prefix)")
fi

array+=("")

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
    if _koopa_is_macos
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
    shell_version="$(_koopa_get_version "${shell_name}")"
    shell="${shell_name} ${shell_version}"
    unset -v shell_name shell_version
    array+=(
        "System information"
        "------------------"
        "OS: ${os}"
        "Shell: ${shell}"
        ""
    )
fi

array+=("Run 'koopa check' to verify installation.")

cat "${koopa_prefix}/system/include/koopa/ascii-turtle.txt"
_koopa_info_box "${array[@]}"
