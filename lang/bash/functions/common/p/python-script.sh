#!/usr/bin/env bash

koopa_python_script() {
    # """
    # Run a Python script.
    # @note Updated 2024-04-19.
    # """
    local -A app dict
    koopa_assert_has_args "$#"
    app['python']="$(koopa_locate_python3 --allow-system)"
    koopa_assert_is_installed "${app[@]}"
    dict['prefix']="$(koopa_python_prefix)/scripts"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['cmd_name']="${1:?}"
    shift 1
    app['script']="${dict['prefix']}/${dict['cmd_name']}"
    koopa_assert_is_executable "${app['script']}"
    "${app['python']}" "${app['script']}" "$@"
    return 0
}
