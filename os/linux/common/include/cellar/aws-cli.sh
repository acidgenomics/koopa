#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# Homebrew recipe, for reference:
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/awscli.rb
#
# Note that the AWS bundled installer isn't versioned in the file name, so we
# need to detect and place in the cellar dynamically instead.
#
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
# https://github.com/aws/aws-cli
#
# Alternate approach, using source code on GitHub:
# > file="${version}.tar.gz"
# > url="https://github.com/aws/${name}/archive/${file}"
# > [...]
# > python3 setup.py install
# """

koopa::assert_is_linux
file='awscli-exe-linux-x86_64.zip'
url="https://awscli.amazonaws.com/${file}"
koopa::download "$url"
koopa::extract "$file"
tmp_install_dir='tmp_install'
tmp_bin_dir='tmp_bin'
./aws/install -i "$tmp_install_dir" -b "$tmp_bin_dir" > /dev/null
koopa::cd "${tmp_install_dir}/v2"
# Note that directory structure currently returns differently for Alpine.
version2="$(find . -mindepth 1 -maxdepth 1 -type d -name '2.*')"
[[ -z "$version2" ]] && koopa::stop 'Failed to detect version.'
version2="$(basename "$version2")"
koopa::sys_cp "$version2" "$prefix"
