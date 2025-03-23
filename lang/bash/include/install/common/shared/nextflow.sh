#!/usr/bin/env bash

main() {
    # """
    # Install Nextflow.
    # @note Updated 2023-04-24.
    #
    # @seealso
    # - https://github.com/nextflow-io/nextflow/
    # - https://get.nextflow.io/
    # - https://nextflow.io/releases/v${dict['version']}/nextflow
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['temurin']="$(koopa_app_prefix 'temurin')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_assert_is_dir "${dict['temurin']}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    koopa_download 'https://get.nextflow.io' 'nextflow'
    export NXF_HOME="${dict['prefix']}/libexec"
    export NXF_JAVA_HOME="${dict['temurin']}"
    export NXF_VER="${dict['version']}"
    koopa_chmod +x 'nextflow'
    ./nextflow
    koopa_cp --target-directory="${dict['libexec']}" 'nextflow'
    read -r -d '' "dict[bin_string]" << END || true
#!/bin/sh
set -o errexit
set -o nounset

export NXF_JAVA_HOME='${dict['temurin']}'
'${dict['libexec']}/nextflow' "\$@"
END
    koopa_write_string \
        --file="${dict['prefix']}/bin/nextflow" \
        --string="${dict['bin_string']}"
    koopa_chmod +x "${dict['prefix']}/bin/nextflow"
    "${dict['prefix']}/bin/nextflow" -version
    koopa_rm "${dict['libexec']}/tmp"
    return 0
}
