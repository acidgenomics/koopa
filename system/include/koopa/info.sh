#!/usr/bin/env bash

# Get the latest commit.
koopa_prefix="$(_koopa_prefix)"

array=(
    "koopa $(_koopa_version) ($(_koopa_date))"
    "URL: $(_koopa_url)"
    "GitHub URL: $(_koopa_github_url)"
)

if _koopa_is_git_toplevel "$koopa_prefix"
then
    origin="$( \
        cd "$koopa_prefix" || exit 1; \
        git config --get remote.origin.url \
    )"
    array+=(
        "Git Remote: ${origin}"
        "Commit: $(_koopa_commit)"
    )
fi

array+=(
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
    readarray -t nf <<< "$(neofetch --stdout)"
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
