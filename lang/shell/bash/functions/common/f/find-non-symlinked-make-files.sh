#!/usr/bin/env bash

koopa_find_non_symlinked_make_files() {
    # """
    # Find non-symlinked make files.
    # @note Updated 2022-02-24.
    # """
    local dict find_args
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [brew_prefix]="$(koopa_homebrew_prefix)"
        [make_prefix]="$(koopa_make_prefix)"
    )
    find_args=(
        '--min-depth' 1
        '--prefix' "${dict[make_prefix]}"
        '--sort'
        '--type' 'f'
    )
    if koopa_is_linux
    then
        find_args+=(
            '--exclude' 'share/applications/**'
            '--exclude' 'share/emacs/site-lisp/**'
            '--exclude' 'share/zsh/site-functions/**'
        )
    elif koopa_is_macos
    then
        find_args+=(
            '--exclude' 'MacGPG2/**'
            '--exclude' 'gfortran/**'
            '--exclude' 'texlive/**'
        )
    fi
    if [[ "${dict[brew_prefix]}" == "${dict[make_prefix]}" ]]
    then
        find_args+=(
            '--exclude' 'Caskroom/**'
            '--exclude' 'Cellar/**'
            '--exclude' 'Homebrew/**'
            '--exclude' 'var/homebrew/**'
        )
    fi
    dict[out]="$(koopa_find "${find_args[@]}")"
    koopa_print "${dict[out]}"
    return 0
}
