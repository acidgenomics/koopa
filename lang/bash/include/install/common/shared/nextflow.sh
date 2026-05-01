#!/usr/bin/env bash

install_from_conda() {
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['libexec']="${dict['prefix']}/libexec"
    _koopa_install_conda_package
    _koopa_rm "${dict['prefix']}/bin/nextflow"
    read -r -d '' "dict[bin_string]" << END || true
#!/bin/sh
set -o errexit
set -o nounset

export NXF_JAVA_HOME='${dict['libexec']}'
'${dict['libexec']}/bin/nextflow' "\$@"
END
    _koopa_write_string \
        --file="${dict['prefix']}/bin/nextflow" \
        --string="${dict['bin_string']}"
    _koopa_chmod +x "${dict['prefix']}/bin/nextflow"
    "${dict['prefix']}/bin/nextflow" -version
    return 0
}

install_from_source() {
    # """
    # Install Nextflow.
    # @note Updated 2026-04-29.
    #
    # @seealso
    # - https://github.com/nextflow-io/nextflow/
    # - https://get.nextflow.io/
    # - https://nextflow.io/releases/v${dict['version']}/nextflow
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['temurin']="$(_koopa_app_prefix 'temurin')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    _koopa_assert_is_dir "${dict['temurin']}"
    dict['libexec']="$(_koopa_init_dir "${dict['prefix']}/libexec")"
    _koopa_download 'https://get.nextflow.io' 'nextflow'
    export NXF_HOME="${dict['libexec']}"
    export NXF_JAVA_HOME="${dict['temurin']}"
    export NXF_VER="${dict['version']}"
    _koopa_chmod +x 'nextflow'
    ./nextflow
    _koopa_cp --target-directory="${dict['libexec']}/bin" 'nextflow'
    read -r -d '' "dict[bin_string]" << END || true
#!/bin/sh
set -o errexit
set -o nounset

export NXF_JAVA_HOME='${dict['temurin']}'
'${dict['libexec']}/bin/nextflow' "\$@"
END
    _koopa_write_string \
        --file="${dict['prefix']}/bin/nextflow" \
        --string="${dict['bin_string']}"
    _koopa_chmod +x "${dict['prefix']}/bin/nextflow"
    "${dict['prefix']}/bin/nextflow" -version
    _koopa_rm "${dict['libexec']}/tmp"
    return 0
}

main() {
    install_from_conda
    return 0
}
