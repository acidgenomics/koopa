#!/usr/bin/env bash

# shellcheck disable=SC2120
koopa::update_conda() { # {{{1
    # """
    # Update Conda.
    # @note Updated 2020-07-11.
    # """
    local force
    force=0
    while (("$#"))
    do
        case "$1" in
            --force)
                force=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::conda_prefix)"
    koopa::assert_is_dir "$prefix"
    if [[ "$force" -eq 0 ]]
    then
        if koopa::is_anaconda
        then
            koopa::note 'Update not supported for Anaconda.'
            return 0
        fi
        koopa::exit_if_current_version conda
    fi
    koopa::h1 "Updating Conda at '${prefix}'."
    conda="${prefix}/condabin/conda"
    koopa::assert_is_file "$conda"
    (
        "$conda" update --yes --name='base' --channel='defaults' conda
        "$conda" update --yes --name='base' --channel='defaults' --all
        # > "$conda" clean --yes --tarballs
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::remove_broken_symlinks "$prefix"
    koopa::sys_set_permissions -r "$prefix"
    return 0
}

koopa::update_conda_envs() { # {{{1
    local conda conda_prefix envs prefix
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed conda
    conda_prefix="$(koopa::conda_prefix)"
    koopa::assert_is_dir "$conda_prefix"
    conda="${conda_prefix}/condabin/conda"
    koopa::assert_is_file conda
    readarray -t envs <<< "$( \
        find "${conda_prefix}/envs" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
            -print \
            | sort \
    )"
    if ! koopa::is_array_non_empty "${envs[@]}"
    then
        koopa::note 'Failed to detect any conda environments.'
        return 0
    fi
    # shellcheck disable=SC2119
    koopa::update_conda
    koopa::h1 "Updating ${#envs[@]} environments at \"${conda_prefix}\"."
    for prefix in "${envs[@]}"
    do
        koopa::h2 "Updating \"${prefix}\"."
        "$conda" update -y --prefix="$prefix" --all
    done
    # > "$conda" clean --yes --tarballs
    koopa::sys_set_permissions -r "$conda_prefix"
    return 0
}

