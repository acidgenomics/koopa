#!/usr/bin/env bash

koopa::git_submodule_init() {
    # """
    # Initialize git submodules.
    # @note Updated 2020-06-20.
    # """
    koopa::assert_has_no_args "$#"
    koopa::h2 "Initializing submodules in '${PWD:?}'."
    koopa::assert_is_git_toplevel "$PWD"
    koopa::assert_is_nonzero_file ".gitmodules"
    koopa::assert_is_installed git
    local array lines string target target_key url url_key
    git submodule init
    lines="$( \
        git config \
            -f ".gitmodules" \
            --get-regexp '^submodule\..*\.path$' \
    )"
    readarray -t array <<< "$lines"
    if ! koopa::is_array_non_empty "${array[@]}"
    then
        koopa::stop "Failed to detect submodules in '${PWD}'."
    fi
    for string in "${array[@]}"
    do
        target_key="$(koopa::print "$string" | cut -d ' ' -f 1)"
        target="$(koopa::print "$string" | cut -d ' ' -f 2)"
        url_key="${target_key//\.path/.url}"
        url="$(git config -f ".gitmodules" --get "$url_key")"
        koopa::dl "$target" "$url"
        if [[ ! -d "$target" ]]
        then
            git submodule add --force "$url" "$target" > /dev/null
        fi
    done
    return 0
}

koopa::git_pull() {
    # """
    # Pull (update) a git repository.
    # @note Updated 2020-06-19.
    #
    # Can quiet down with 'git submodule --quiet' here.
    # Note that git checkout, fetch, and pull also support '--quiet'.
    #
    # @seealso
    # - https://git-scm.com/docs/git-submodule/2.10.2
    # """
    koopa::h2 "Pulling git repo at '${PWD:?}'."
    koopa::assert_is_git_toplevel "$PWD"
    koopa::assert_is_installed git
    git fetch --all
    git pull "$@"
    if [[ -s ".gitmodules" ]]
    then
        koopa::git_submodule_init
        git submodule --quiet update --init --recursive
        git submodule --quiet foreach --recursive \
            git fetch --all --quiet
        git submodule --quiet foreach --recursive \
            git checkout master --quiet
        git submodule --quiet foreach --recursive \
            git pull origin master
    fi
    koopa::success "Pull was successful."
    return 0
}

koopa::git_reset() { # {{{1
    # """
    # Clean and reset a git repo and its submodules.
    # @note Updated 2020-04-30.
    #
    # Note extra '-f' flag in 'git clean' step, which handles nested '.git'
    # directories better.
    #
    # Additional steps:
    # # Ensure accidental swap files created by vim get nuked.
    # > find . -type f -name "*.swp" -delete
    # # Ensure invisible files get nuked on macOS.
    # > if koopa::is_macos
    # > then
    # >     find . -type f -name ".DS_Store" -delete
    # > fi
    #
    # See also:
    # https://gist.github.com/nicktoumpelis/11214362
    # """
    koopa::assert_has_no_args "$#"
    koopa::h2 "Resetting git repo at '${PWD:?}'."
    koopa::assert_is_git_toplevel "$PWD"
    koopa::assert_is_installed git
    git clean -dffx
    if [[ -s ".gitmodules" ]]
    then
        koopa::git_submodule_init
        git submodule --quiet foreach --recursive git clean -dffx
        git reset --hard --quiet
        git submodule --quiet foreach --recursive git reset --hard --quiet
    fi
    return 0
}
