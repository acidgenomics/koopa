#!/usr/bin/env bash

koopa_md5sum_check_parallel() {
    # """
    # Run md5sum checks in parallel.
    # @note Updated 2023-02-01.
    #
    # @seealso
    # - https://github.com/FarisHijazi/commands/blob/master/handy-commandline.md
    # - https://stackoverflow.com/questions/34082325/
    # - https://stackoverflow.com/questions/36920307/
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['md5sum']="$(koopa_locate_md5sum)"
    app['sh']="$(koopa_locate_sh)"
    app['xargs']="$(koopa_locate_xargs)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    koopa_find \
        --max-depth=1 \
        --min-depth=1 \
        --pattern='*.md5' \
        --prefix='.' \
        --print0 \
        --sort \
        --type='f' \
    | "${app['xargs']}" \
        -0 \
        -I {} \
        -P "${dict['jobs']}" \
            "${app['sh']}" -c "${app['md5sum']} -c {}"
    return 0
}
