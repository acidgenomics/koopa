#!/usr/bin/env bash

koopa_perl_file_rename_version() {
    # """
    # Perl 'File::Rename' module version.
    # @note Updated 2022-03-18.
    # """
    koopa_assert_has_no_args "$#"
    koopa_perl_package_version 'File::Rename'
}
