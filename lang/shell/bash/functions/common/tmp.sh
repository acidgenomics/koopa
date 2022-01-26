#!/usr/bin/env bash

koopa::mktemp() { # {{{1
    # """
    # Wrapper function for system 'mktemp'.
    # @note Updated 2022-01-26.
    #
    # Traditionally, many shell scripts take the name of the program with the
    # pid as a suffix and use that as a temporary file name. This kind of
    # naming scheme is predictable and the race condition it creates is easy for
    # an attacker to win. A safer, though still inferior, approach is to make a
    # temporary directory using the same naming scheme. While this does allow
    # one to guarantee that a temporary file will not be subverted, it still
    # allows a simple denial of service attack. For these reasons it is
    # suggested that mktemp be used instead.
    #
    # Note that old version of mktemp (e.g. macOS) only supports '-t' instead of
    # '--tmpdir' flag for prefix.
    #
    # @seealso
    # - https://st xackoverflow.com/questions/4632028
    # - https://stackoverflow.com/a/10983009/3911732
    # - https://gist.github.com/earthgecko/3089509
    # """
    local app dict mktemp_args x
    declare -A app=(
        [mktemp]="$(koopa::locate_mktemp)"
    )
    declare -A dict=(
        [date_id]="$(koopa::datetime)"
        [user_id]="$(koopa::user_id)"
    )
    dict[template]="koopa-${dict[user_id]}-${dict[date_id]}-XXXXXXXXXX"
    mktemp_args=(
        "$@"
        '-t' "${dict[template]}"
    )
    x="$("${app[mktemp]}" "${mktemp_args[@]}")"
    koopa::print "$x"
    return 0
}

koopa::tmp_dir() { # {{{1
    # """
    # Create temporary directory.
    # @note Updated 2020-05-06.
    # """
    local x
    koopa::assert_has_no_args "$#"
    x="$(koopa::mktemp -d)"
    koopa::assert_is_dir "$x"
    koopa::print "$x"
    return 0
}

koopa::tmp_file() { # {{{1
    # """
    # Create temporary file.
    # @note Updated 2021-05-06.
    # """
    local x
    koopa::assert_has_no_args "$#"
    x="$(koopa::mktemp)"
    koopa::assert_is_file "$x"
    koopa::print "$x"
    return 0
}

koopa::tmp_log_file() { # {{{1
    # """
    # Create temporary log file.
    # @note Updated 2020-11-23.
    #
    # Used primarily for debugging installation scripts.
    #
    # Note that mktemp on macOS and BusyBox doesn't support '--suffix' flag.
    # Otherwise, we can use:
    # > koopa::mktemp --suffix='.log'
    # """
    koopa::assert_has_no_args "$#"
    koopa::tmp_file
    return 0
}

koopa::view_latest_tmp_log_file() { # {{{1
    # """
    # View the latest temporary log file.
    # @note Updated 2022-01-17.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [tail]="$(koopa::locate_tail)"
    )
    declare -A dict=(
        [tmp_dir]="${TMPDIR:-/tmp}"
        [user_id]="$(koopa::user_id)"
    )
    dict[log_file]="$( \
        koopa::find \
            --glob="koopa-${dict[user_id]}-*" \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict[tmp_dir]}" \
            --sort \
            --type='f' \
        | "${app[tail]}" -n 1 \
    )"
    if [[ ! -f "${dict[log_file]}" ]]
    then
        koopa::stop "No koopa log file detected in '${dict[tmp_dir]}'."
    fi
    koopa::alert "Viewing '${dict[log_file]}'."
    # The use of '+G' flag here forces pager to return at end of line.
    koopa::pager +G "${dict[log_file]}"
    return 0
}
