#!/usr/bin/env bash

koopa_python_system_packages_prefix() {
    # """
    # Python system site packages library prefix.
    # @note Updated 2023-02-13.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    local -A app dict
    app['python']="${1:?}"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$( \
        "${app['python']}" -c 'import site; print(site.getsitepackages()[0])' \
    )"
    koopa_assert_is_dir "${dict['prefix']}"
    koopa_print "${dict['prefix']}"
    return 0
}
