#!/bin/sh
# shellcheck disable=SC2039



# Get conda environment name for prompt string.
# Updated 2019-08-17.
_koopa_prompt_conda_env() {
    local name
    if [ -n "${CONDA_DEFAULT_ENV:-}" ]
    then
        name="$CONDA_DEFAULT_ENV"
    else
        name=""
    fi
    [ -n "$name" ] && printf " [conda: %s]" "${name}"
}



_koopa_prompt_disk_used() {
    local pct used
    used="$(_koopa_disk_pct_used)"
    case "$KOOPA_SHELL" in
        zsh) pct="%%" ;;
        *) pct="%" ;;
    esac
    printf " [disk: %d%s]" "$used" "$pct"
}



# Updated 2019-08-17.
_koopa_prompt_os() {
    local id
    local string
    local version
    
    if _koopa_is_darwin
    then
        string="$(_koopa_macos_version_short)"
    elif _koopa_is_linux
    then
        id="$( \
            awk -F= '$1=="ID" { print $2 ;}' /etc/os-release | \
            tr -d '"' \
        )"
        version="$( \
            awk -F= '$1=="VERSION_ID" { print $2 ;}' /etc/os-release | \
            tr -d '"' \
        )"
        string="${id} ${version}"
    else
        string=""
    fi
    
    if _koopa_is_remote
    then
        host_type="$(_koopa_host_type)"
        if [ -n "$host_type" ]
        then
            string="${host_type} ${string1}"
        fi
    fi
    
    echo "$string"
}



# Get Python virtual environment name for prompt string.
# https://stackoverflow.com/questions/10406926
# Updated 2019-08-17.
_koopa_prompt_python_env() {
    local name
    if [ -n "${VIRTUAL_ENV:-}" ]
    then
        # Strip out the path and just leave the env name.
        name="${VIRTUAL_ENV##*/}"
    else
        name=""
    fi
    [ -n "$name" ] && printf " [venv: %s]" "$name"
}
