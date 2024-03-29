#!/usr/bin/env bash

# FIXME The Perl scripts in bin currently don't work unless we activate the
# conda environment. Need to rework this to patch.

main() {
    # """
    # Install agat.
    # @note Updated 2023-08-30.
    # """
    local -A app dict
    app['patch']="$(koopa_locate_patch)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    koopa_install_conda_package
    # Generated using 'diff -u agat agat-1 > agat.patch'.
    dict['patch_file']='agat.patch'
    read -r -d '' "dict[patch_string]" << END || true
--- agat	2022-11-14 12:24:17
+++ agat-1	2022-11-14 13:15:20
@@ -1,4 +1,5 @@
-#!/usr/bin/env perl
+#!${dict['prefix']}/libexec/bin/perl -w
+use lib "${dict['prefix']}/libexec/lib/perl5";
 use v5.24;
 use warnings;
 use experimental 'signatures';
END
    koopa_write_string \
        --file="${dict['patch_file']}" \
        --string="${dict['patch_string']}"
    dict['patch_file']="$(koopa_realpath "${dict['patch_file']}")"
    (
        koopa_cd "${dict['prefix']}/libexec/bin"
        "${app['patch']}" 'agat' "${dict['patch_file']}"
    )
    return 0
}
