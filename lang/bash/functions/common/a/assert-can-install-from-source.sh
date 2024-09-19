#!/usr/bin/env bash

koopa_assert_can_install_from_source() {
    # """
    # Assert that current environment supports building from source.
    # @note Updated 2024-09-19.
    # """
    local -A app version
    koopa_assert_has_no_args "$#"
    koopa_assert_conda_env_is_not_active
    # > koopa_assert_python_venv_is_not_active
    app['cc']="$(koopa_locate_cc --only-system)"
    app['git']="$(koopa_locate_git --allow-system)"
    app['ld']="$(koopa_locate_ld --only-system)"
    app['make']="$(koopa_locate_make --only-system)"
    app['perl']="$(koopa_locate_perl --only-system)"
    app['python']="$(koopa_locate_python3 --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    version['cc']="$(koopa_get_version "${app['cc']}")"
    version['git']="$(koopa_get_version "${app['git']}")"
    version['ld']="$(koopa_get_version "${app['ld']}")"
    version['make']="$(koopa_get_version "${app['make']}")"
    version['perl']="$(koopa_get_version "${app['perl']}")"
    version['python']="$(koopa_get_version "${app['python']}")"
    return 0
}
