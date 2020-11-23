#!/usr/bin/env bash

koopa::mktemp() { # {{{1
    # """
    # Wrapper function for system 'mktemp'.
    # @note Updated 2020-07-04.
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
    # See also:
    # - https://stackoverflow.com/questions/4632028
    # - https://stackoverflow.com/a/10983009/3911732
    # - https://gist.github.com/earthgecko/3089509
    # """
    koopa::assert_is_installed mktemp
    local date_id template user_id
    user_id="$(koopa::user_id)"
    date_id="$(koopa::datetime)"
    template="koopa-${user_id}-${date_id}-XXXXXXXXXX"
    mktemp "$@" -t "$template"
    return 0
}

koopa::tmp_dir() { # {{{1
    # """
    # Create temporary directory.
    # @note Updated 2020-02-06.
    # """
    koopa::assert_has_no_args "$#"
    koopa::mktemp -d
    return 0
}

koopa::tmp_file() { # {{{1
    # """
    # Create temporary file.
    # @note Updated 2020-02-06.
    # """
    koopa::assert_has_no_args "$#"
    koopa::mktemp
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
    # @note Updated 2020-07-05.
    # """
    local dir log_file
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed find
    dir="${TMPDIR:-/tmp}"
    log_file="$( \
        find "$dir" \
            -mindepth 1 \
            -maxdepth 1 \
            -type f \
            -name "koopa-$(koopa::user_id)-*" \
            | sort \
            | tail -n 1 \
    )"
    [[ -f "$log_file" ]] || return 1
    koopa::info "Viewing '${log_file}'."
    # Note that this will skip to the end automatically.
    koopa::pager +G "$log_file"
    return 0
}
