#!/usr/bin/env bash

# FIXME Now seeing this error specifically on macOS, but not Linux:
#
# mkdir -p "/opt/koopa/app/chezmoi/2.19.0/bin"
# install -m 755 --target-directory "/opt/koopa/app/chezmoi/2.19.0/bin" chezmoi
# install: illegal option -- -
# usage: install [-bCcpSsv] [-B suffix] [-f flags] [-g group] [-m mode]
#                [-o owner] file1 file2
#        install [-bCcpSsv] [-B suffix] [-f flags] [-g group] [-m mode]
#                [-o owner] file1 ... fileN directory
#        install -d [-v] [-g group] [-m mode] [-o owner] directory ...
# make: *** [Makefile:35: install] Error 64

main() {
    # """
    # Install chezmoi.
    # @note Updated 2022-07-28.
    #
    # @seealso
    # - https://www.chezmoi.io/
    # - https://github.com/twpayne/chezmoi
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/chezmoi.rb
    # - https://ports.macports.org/port/chezmoi/details/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'go'
    declare -A app=(
        [go]="$(koopa_locate_go)"
    )
    [[ -x "${app[go]}" ]] || return 1
    declare -A dict=(
        [gopath]="$(koopa_init_dir 'go')"
        [name]='chezmoi'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/twpayne/chezmoi/archive/\
refs/tags/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    export GOPATH="${dict[gopath]}"
    dict[ldflags]="-X main.version=${dict[version]}"
    "${app[go]}" build -ldflags "${dict[ldflags]}"
    koopa_cp --target-directory="${dict[prefix]}/bin" 'chezmoi'
    koopa_chmod --recursive 'u+rw' "${dict[gopath]}"
    koopa_configure_chezmoi
    return 0
}
