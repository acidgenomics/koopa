#!/usr/bin/env bash

# FIXME We need to version pin here.

linux_install_aws_cli() { # {{{1
    # """
    # Install AWS CLI.
    # @note Updated 2021-11-16.
    #
    # Note that the AWS bundled installer isn't versioned in the file name.
    #
    # Alternate approach, using source code on GitHub:
    # > file="${version}.tar.gz"
    # > url="https://github.com/aws/${name}/archive/${file}"
    # > [...]
    # > python3 setup.py install
    #
    # @seealso
    # - https://docs.aws.amazon.com/cli/latest/userguide/
    #     install-cliv2-linux.html
    # - https://github.com/aws/aws-cli
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/awscli.rb
    # """
    local dict
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [prefix]="${INSTALL_PREFIX:?}"
        [tmp_bin_dir]='tmp_bin'
        [tmp_install_dir]='tmp_install'
    )
    dict[file]="awscli-exe-linux-${dict[arch]}.zip"
    dict[url]="https://awscli.amazonaws.com/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    ./aws/install \
        -i "${dict[tmp_install_dir]}" \
        -b "${dict[tmp_bin_dir]}" \
        > /dev/null
    koopa_cd "${dict[tmp_install_dir]}/v2"
    # Note that directory structure currently returns differently for Alpine.
    dict[version_subdir]="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='2.*' \
            --prefix="${PWD:?}" \
            --type='d' \
    )"
    if [[ -z "${dict[version_subdir]}" ]]
    then
        koopa_stop 'Failed to detect version.'
    fi
    koopa_sys_cp "${dict[version_subdir]}" "${dict[prefix]}"
    return 0
}
