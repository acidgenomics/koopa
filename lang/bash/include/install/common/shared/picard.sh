#!/usr/bin/env bash

main() {
    # """
    # Install picard.
    # @note Updated 2023-08-30.
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    _koopa_install_conda_package
    dict['jvm_prefix']="${dict['prefix']}/libexec/lib/jvm"
    _koopa_assert_is_dir "${dict['jvm_prefix']}"
    dict['picard_file']="${dict['prefix']}/bin/picard"
    dict['picard_libexec_file']="${dict['prefix']}/libexec/bin/picard"
    _koopa_assert_is_file \
        "${dict['picard_file']}" \
        "${dict['picard_libexec_file']}"
    read -r -d '' "dict[picard_string]" << END || true
#!/usr/bin/env bash
set -Eeuo pipefail

export JAVA_HOME=${dict['jvm_prefix']}
${dict['picard_libexec_file']} "\$@"
END
    _koopa_rm "${dict['picard_file']}"
    _koopa_write_string \
        --file="${dict['picard_file']}" \
        --string="${dict['picard_string']}"
    _koopa_chmod +x "${dict['picard_file']}"
    return 0
}
