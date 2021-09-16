#!/usr/bin/env bash

# [2021-05-27] Ubuntu success.

koopa::linux_install_aws_cli() { # {{{1
    koopa:::install_app \
        --name='aws-cli' \
        --name-fancy='AWS CLI' \
        --link-include-dirs='bin' \
        --platform='linux' \
        --version='rolling' \
        "$@"
}

koopa:::linux_install_aws_cli() { # {{{1
    # """
    # Install AWS CLI.
    # @note Updated 2021-05-05.
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
    local arch file prefix tmp_bin_dir tmp_install_dir url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    arch="$(koopa::arch)"
    file="awscli-exe-linux-${arch}.zip"
    url="https://awscli.amazonaws.com/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    tmp_install_dir='tmp_install'
    tmp_bin_dir='tmp_bin'
    ./aws/install -i "$tmp_install_dir" -b "$tmp_bin_dir" > /dev/null
    koopa::cd "${tmp_install_dir}/v2"
    # Note that directory structure currently returns differently for Alpine.
    version="$(find . -mindepth 1 -maxdepth 1 -type d -name '2.*')"
    [[ -z "$version" ]] && koopa::stop 'Failed to detect version.'
    version="$(basename "$version")"
    koopa::sys_cp "$version" "$prefix"
    return 0
}

koopa::linux_uninstall_aws_cli() { # {{{1
    # """
    # Uninstall AWS CLI.
    # @note Updated 2021-06-11.
    # """
    koopa:::uninstall_app \
        --name='aws-cli' \
        --name-fancy='AWS CLI' \
        "$@"
}
