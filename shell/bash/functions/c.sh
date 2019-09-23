#!/usr/bin/env bash



# Create an internal conda environment.
#
# See also: conda create --help
#
# Note that we're allowing word splitting on the apps argument here.
#
# Updated 2019-09-23.
_koopa_create_conda_env() {
    _koopa_assert_is_installed conda

    local prefix
    prefix="$(_koopa_conda_prefix)"

    local internal
    internal=0

    local POSITIONAL
    POSITIONAL=()
    for i in "$@"
    do
        case "$i" in
            --internal)
                internal=1
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                >&2 printf "Error: Invalid argument: '%s'\n" "$i"
                return 1
                ;;
            *)
                POSITIONAL+=("$i")
                shift 1
                ;;
        esac
    done
    set -- "${POSITIONAL[@]}"

    local name
    name="$1"
    shift 1

    local programs
    programs=("$@")

    local flags
    flags=()
    if [[ "$internal" -eq 1 ]]
    then
        flags+=("--prefix=${prefix}/envs/${name}")
    else
        flags+=("--name=${name}")
    fi

    conda create -qy "${flags[@]}" "${programs[@]}"
}
