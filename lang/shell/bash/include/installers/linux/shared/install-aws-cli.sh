#!/usr/bin/env bash

main() {
    # """
    # Install AWS CLI binary.
    # @note Updated 2022-04-07.
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
    #     getting-started-install.html
    # - https://docs.aws.amazon.com/cli/latest/userguide/
    #     install-cliv2-linux.html
    # - https://github.com/awsdocs/aws-cli-user-guide/blob/main/doc_source/
    #     install-cliv2-linux.md
    # - https://github.com/aws/aws-cli/tree/v2
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/awscli.rb
    # """
    local dict
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
        [tmp_bin_dir]='tmp_bin'
        [tmp_install_dir]='tmp_install'
    )
    dict[file]="awscli-exe-linux-${dict[arch]}-${dict[version]}.zip"
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
    koopa_cp "${dict[version_subdir]}" "${dict[prefix]}"
    return 0
}
