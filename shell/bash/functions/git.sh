#!/usr/bin/env bash

_koopa_git_submodule_init() {
    # """
    # Initialize git submodules.
    # @note Updated 2020-02-18.
    # """
    _koopa_h2 "Initializing submodules in '${PWD:?}'."
    [[ "$#" -eq 0 ]] || return 1
    _koopa_assert_is_git "$PWD"
    _koopa_assert_is_file ".gitmodules"
    _koopa_assert_is_installed git
    local array string target target_key url url_key
    git submodule init
    mapfile -t array \
        < <( \
            git config \
                -f ".gitmodules" \
                --get-regexp '^submodule\..*\.path$' \
        )
    for string in "${array[@]}"
    do
        target_key="$(echo "$string" | cut -d ' ' -f 1)"
        target="$(echo "$string" | cut -d ' ' -f 2)"
        url_key="${target_key//\.path/.url}"
        url="$(git config -f ".gitmodules" --get "$url_key")"
        _koopa_dl "$target" "$url"
        if [[ ! -d "$target" ]]
        then
            git submodule add --force "$url" "$target" > /dev/null
        fi
    done
    return 0
}

_koopa_git_pull() {
    # """
    # Pull (update) a git repository.
    # @note Updated 2020-02-24.
    # """
    _koopa_h2 "Pulling git repo at '${PWD:?}'."
    [[ "$#" -eq 0 ]] || return 1
    _koopa_assert_is_git "$PWD"
    _koopa_assert_is_installed git
    git fetch --all  # --quiet
    git pull  # --quiet
    if [[ -f ".gitmodules" ]]
    then
        _koopa_git_submodule_init
        # Can quiet down with 'git submodule --quiet' here.
        git submodule update --init --recursive
        # > git submodule foreach -q --recursive git checkout master  # --quiet
        git submodule foreach git pull  # --quiet
    fi
    return 0
}

_koopa_git_reset() {  # {{{1
    # """
    # Clean and reset a git repo and its submodules.
    # @note Updated 2020-02-16.
    #
    # Note extra '-f' flag in 'git clean' step, which handles nested '.git'
    # directories better.
    #
    # Additional steps:
    # # Ensure accidental swap files created by vim get nuked.
    # > find . -type f -name "*.swp" -delete
    # # Ensure invisible files get nuked on macOS.
    # > if _koopa_is_macos
    # > then
    # >     find . -type f -name ".DS_Store" -delete
    # > fi
    #
    # See also:
    # https://gist.github.com/nicktoumpelis/11214362
    # """
    _koopa_h2 "Resetting git repo at '${PWD:?}'."
    [[ "$#" -eq 0 ]] || return 1
    _koopa_assert_is_git "$PWD"
    _koopa_assert_is_installed git
    git clean -dffx
    if [[ -f ".gitmodules" ]]
    then
        _koopa_git_submodule_init
        git submodule --quiet foreach --recursive git clean -dffx
        git reset --hard --quiet
        git submodule --quiet foreach --recursive git reset --hard --quiet
    fi
    return 0
}
