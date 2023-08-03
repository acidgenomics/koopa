#!/usr/bin/env bash

koopa_mktemp() {
    # """
    # Wrapper function for system 'mktemp'.
    # @note Updated 2023-08-03.
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
    local -A app dict
    local -a mktemp_args
    app['mktemp']="$(koopa_locate_mktemp --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['template']='koopa'
    if koopa_is_gnu "${app['mktemp']}"
    then
        dict['template']="${dict['template']}.XXXXXXXXXXXX"
    fi
    mktemp_args=("$@" '-t' "${dict['template']}")
    dict['out']="$("${app['mktemp']}" "${mktemp_args[@]}")"
    [[ -e "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}
