#!/usr/bin/env bash

# FIXME Now seeing this error on macOS (2022-01-06):
#  GEN /private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/koopa-501-20220106-110831-kzrpdtLIgJ/singularity-ce-3.9.2/scripts/go-generate
#  GO singularity
#     [+] GO_TAGS "containers_image_openpgp exclude_graphdriver_btrfs exclude_graphdriver_devicemapper sylog oci_engine singularity_engine fakeroot_engine"
# package github.com/sylabs/singularity/cmd/singularity
# 	imports github.com/sylabs/singularity/cmd/internal/cli
# 	imports github.com/sylabs/singularity/internal/app/singularity
# 	imports github.com/sylabs/singularity/pkg/image
# 	imports github.com/sylabs/singularity/internal/pkg/util/user
# 	imports github.com/sylabs/singularity/pkg/util/namespaces: build constraints exclude all Go files in /private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/koopa-501-20220106-110831-kzrpdtLIgJ/singularity-ce-3.9.2/pkg/util/namespaces
# make: *** [Makefile:169: singularity] Error 1
# make: Leaving directory '/private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/koopa-501-20220106-110831-kzrpdtLIgJ/singularity-ce-3.9.2/builddir'

koopa:::install_singularity() { # {{{1
    # """
    # Install Singularity.
    # @note Updated 2022-01-06.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [name]='singularity-ce'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://github.com/sylabs/singularity/releases/download/\
v${dict[version]}/${dict[file]}"
    if koopa::is_linux
    then
        koopa::activate_opt_prefix 'go'
    elif koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix 'go'
    fi
    koopa::assert_is_installed 'go'
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    ./mconfig --prefix="${dict[prefix]}"
    "${app[make]}" -C builddir
    "${app[make]}" -C builddir install
    return 0
}
