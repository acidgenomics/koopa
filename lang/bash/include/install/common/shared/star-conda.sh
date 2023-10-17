#!/usr/bin/env bash

main() {
    # """
    # Install STAR from bioconda.
    # @note Updated 2023-10-17.
    # """
    local -A app dict
    app['patch']="$(koopa_locate_patch)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    koopa_install_conda_package
    if koopa_is_linux
    then
        dict['patch_file']='patch-script-dir.patch'
        read -r -d '' "dict[patch_string]" << END || true
3c3
< SCRIPT_DIR=\$( cd -- "\$( dirname -- "\${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
---
> SCRIPT_DIR=${dict['prefix']}
END
        koopa_write_lines \
            --file="${dict['patch_file']}" \
            --string="${dict['patch_string']}"
        "${app['patch']}" \
            --unified \
            --verbose \
            "${dict['prefix']}/libexec/bin/STAR" \
            "${dict['patch_file']}"
        "${app['patch']}" \
            --unified \
            --verbose \
            "${dict['prefix']}/libexec/bin/STARlong" \
            "${dict['patch_file']}"
    fi
    "${dict['prefix']}/bin/STAR" -h
    "${dict['prefix']}/bin/STARlong" -h
    return 0
}
