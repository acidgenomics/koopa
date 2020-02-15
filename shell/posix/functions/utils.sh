#!/bin/sh
# shellcheck disable=SC2039

_koopa_array_to_r_vector() {  # {{{1
    # """
    # Convert a bash array to an R vector string.
    # @note Updated 2019-09-25.
    #
    # Example: ("aaa" "bbb") array to 'c("aaa", "bbb")'.
    # """
    local x
    x="$(printf '"%s", ' "$@")"
    x="$(_koopa_strip_right "$x" ", ")"
    printf "c(%s)\n" "$x"
}

_koopa_cpu_count() {  # {{{1
    # """
    # Get the number of cores (CPUs) available.
    # @note Updated 2020-01-31.
    # """
    local n
    if _koopa_is_macos
    then
        n="$(sysctl -n hw.ncpu)"
    elif _koopa_is_linux
    then
        n="$(getconf _NPROCESSORS_ONLN)"
    else
        # Otherwise assume single threaded.
        n=1
    fi
    # Set to n-2 cores, if applicable.
    if [ "$n" -gt 2 ]
    then
        n=$((n - 2))
    fi
    echo "$n"
}

_koopa_quiet_cd() {  # {{{1
    # """
    # Change directory quietly
    # @note Updated 2019-10-29.
    # """
    cd "$@" > /dev/null || return 1
    return 0
}

_koopa_quiet_expr() {  # {{{1
    # """
    # Quiet regular expression matching that is POSIX compliant.
    # @note Updated 2020-01-12.
    #
    # Avoid using '[[ =~ ]]' in sh config files.
    # 'expr' is faster than using 'case'.
    #
    # See also:
    # - https://stackoverflow.com/questions/21115121
    # """
    expr "${1:?}" : "${2:?}" 1>/dev/null
}

_koopa_quiet_rm() {  # {{{1
    # """
    # Remove quietly.
    # @note Updated 2019-10-29.
    # """
    rm -fr "$@" > /dev/null 2>&1
    return 0
}

_koopa_update_git_repo() {  # {{{1
    # """
    # Update a git repository.
    # @note Updated 2020-01-17.
    # """
    local repo
    repo="${1:?}"
    [ -d "${repo}" ] || return 0
    [ -x "${repo}/.git" ] || return 0
    _koopa_h2 "Updating '${repo}'."
    (
        cd "$repo" || exit 1
        # Run updater script, if defined.
        # Otherwise pull the git repo.
        if [[ -x "UPDATE.sh" ]]
        then
            ./UPDATE.sh
        else
            git fetch --all
            git pull
        fi
    )
    return 0
}
