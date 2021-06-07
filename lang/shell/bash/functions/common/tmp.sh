#!/usr/bin/env bash

koopa::mktemp() { # {{{1
    # """
    # Wrapper function for system 'mktemp'.
    # @note Updated 2021-05-21.
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
    local date_id mktemp mktemp_args template user_id
    mktemp="$(koopa::locate_mktemp)"
    mktemp_args=("$@")
    user_id="$(koopa::user_id)"
    date_id="$(koopa::datetime)"
    template="koopa-${user_id}-${date_id}-XXXXXXXXXX"
    mktemp_args+=('-t' "$template")
    x="$("$mktemp" "${mktemp_args[@]}")"
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
    # @note Updated 2021-05-24.
    # """
    local log_file sort tail tmp_dir user_id
    koopa::assert_has_no_args "$#"
    sort="$(koopa::locate_sort)"
    tail="$(koopa::locate_tail)"
    tmp_dir="${TMPDIR:-/tmp}"
    user_id="$(koopa::user_id)"
    log_file="$( \
        koopa::find \
            --glob="koopa-${user_id}-*" \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="$tmp_dir" \
            --type='f' \
        | "$sort" \
        | "$tail" -n 1 \
    )"
    [[ -f "$log_file" ]] || return 1
    koopa::alert "Viewing '${log_file}'."
    # Note that this will skip to the end automatically.
    koopa::pager +G "$log_file"
    return 0
}
