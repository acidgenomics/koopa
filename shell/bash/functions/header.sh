#!/usr/bin/env bash

koopa::header() { # {{{1
    # """
    # Source script header.
    # @note Updated 2020-06-30.
    #
    # Useful for private scripts using koopa code outside of package.
    # """
    local file header_type koopa_prefix
    koopa::assert_has_args_eq "$#" 1
    header_type="${1:?}"
    koopa_prefix="$(koopa::prefix)"
    case "$header_type" in
        # shell ----------------------------------------------------------------
        bash)
            file="${koopa_prefix}/shell/bash/include/header.sh"
            ;;
        zsh)
            file="${koopa_prefix}/shell/zsh/include/header.sh"
            ;;
        # os -------------------------------------------------------------------
        amzn)
            file="${koopa_prefix}/os/amzn/include/header.sh"
            ;;
        centos)
            file="${koopa_prefix}/os/centos/include/header.sh"
            ;;
        darwin)
            file="${koopa_prefix}/os/darwin/include/header.sh"
            ;;
        debian)
            file="${koopa_prefix}/os/debian/include/header.sh"
            ;;
        fedora)
            file="${koopa_prefix}/os/fedora/include/header.sh"
            ;;
        linux)
            file="${koopa_prefix}/os/linux/include/header.sh"
            ;;
        macos)
            file="${koopa_prefix}/os/macos/include/header.sh"
            ;;
        rhel)
            file="${koopa_prefix}/os/rhel/include/header.sh"
            ;;
        ubuntu)
            file="${koopa_prefix}/os/ubuntu/include/header.sh"
            ;;
        # host -----------------------------------------------------------------
        aws)
            file="${koopa_prefix}/host/aws/include/header.sh"
            ;;
        azure)
            file="${koopa_prefix}/host/azure/include/header.sh"
            ;;
        *)
            koopa::invalid_arg "$1"
            ;;
    esac
    koopa::assert_is_file "$file"
    koopa::print "$file"
    return 0
}
