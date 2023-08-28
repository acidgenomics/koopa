#!/usr/bin/env bash

main() {
    local -A dict
    koopa_install_app_subshell \
        --installer='conda-package' \
        --name='picard'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['jvm_prefix']="${dict['prefix']}/libexec/lib/jvm"
    koopa_assert_is_dir "${dict['jvm_prefix']}"
    dict['picard_file']="${dict['prefix']}/bin/picard"
    dict['picard_libexec_file']="${dict['prefix']}/libexec/bin/picard"
    koopa_assert_is_file \
        "${dict['picard_file']}" \
        "${dict['picard_libexec_file']}"
    read -r -d '' "dict[picard_string]" << END || true
#!/usr/bin/env bash
set -Eeuo pipefail

export JAVA_HOME=${dict['jvm_prefix']}
${dict['picard_libexec_file']} "\$@"
END
    koopa_rm "${dict['picard_file']}"
    koopa_write_string \
        --file="${dict['picard_file']}" \
        --string="${dict['picard_string']}"
    koopa_chmod +x "${dict['picard_file']}"
    return 0
}
