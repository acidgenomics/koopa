#!/usr/bin/env bash
# shellcheck disable=SC2039

_koopa_conda_create_env() {
    # """
    # Create a conda environment.
    # @note Updated 2020-03-05.
    # """
    _koopa_assert_has_args "$@"

    local force
    force=0
    local version
    version=

    local pos
    pos=()
    while (("$#"))
    do
        case "$1" in
            --force)
                force=1
                shift 1
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            --version)
                version="$2"
                shift 2
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    set -- "${pos[@]}"

    local name
    name="$1"

    local env_name
    if [[ -n "${version:-}" ]]
    then
        env_name="${name}@${version}"
    else
        env_name="$name"
    fi

    local prefix
    prefix="$(_koopa_conda_prefix)/envs/${env_name}"

    if [[ "$force" -eq 1 ]]
    then
        conda remove --name "$env_name" --all
    fi

    if [[ -d "$prefix" ]]
    then
        _koopa_note "'${env_name}' is installed."
        return 0
    fi

    _koopa_info "Creating '${env_name}' conda environment."

    _koopa_activate_conda
    _koopa_assert_is_installed conda

    local flags
    flags=(
        "--name=${env_name}"
        "--quiet"
        "--yes"
    )

    if [[ -n "${version:-}" ]]
    then
        flags+=("${name}=${version}")
    else
        flags+=("$name")
    fi

    conda create "${flags[@]}"

    _koopa_set_permissions --recursive "$prefix"
    return 0
}
