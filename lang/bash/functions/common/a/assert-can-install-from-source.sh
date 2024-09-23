#!/usr/bin/env bash

# FIXME Don't allow CLT:
# 16.0.0.0.1.1724870825

# FIXME Need to add a koopa_compare_versions function here.
# https://stackoverflow.com/questions/4023830
# koopa_compare_versions AAA OP BBB
# e.g. koopa_compare_versions 2.0 >= 1.0
# Need to support these ops: =, >, >=, <, <=

koopa_assert_can_install_from_source() {
    # """
    # Assert that current environment supports building from source.
    # @note Updated 2024-09-19.
    # """
    local -A app ver1 ver2
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
    ver1['cc']="$(koopa_get_version "${app['cc']}")"
    ver1['git']="$(koopa_get_version "${app['git']}")"
    ver1['make']="$(koopa_get_version "${app['make']}")"
    ver1['perl']="$(koopa_get_version "${app['perl']}")"
    ver1['python']="$(koopa_get_version "${app['python']}")"
    if koopa_is_macos
    then
        # Clang.
        ver2['cc']='14.0'
    elif koopa_is_linux
    then
        # GCC.
        ver2['cc']='4.8'
    fi
    ver2['git']='1.8'
    ver2['make']='3.8'
    ver2['perl']='5.16'
    ver2['python']='3.6'
    # FIXME Loop across ver1 and ver2 and run koopa_compare_versions script.
    return 0
}
