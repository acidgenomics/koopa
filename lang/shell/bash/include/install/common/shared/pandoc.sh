#!/usr/bin/env bash

# FIXME We're not location zlib correctly on Ubuntu...argh.
# Error: cabal: Missing dependency on a foreign library:
# * Missing (or bad) header file: zlib.h
# * Missing (or bad) C library: z
# This problem can usually be solved by installing the system package that
# provides this library (you may need the "-dev" version). If the library is
# already installed but in a non-standard location then you can use the flags
# --extra-include-dirs= and --extra-lib-dirs= to specify where it is.If the
# library file does exist, it may contain errors that are caught by the C
# compiler at the preprocessing stage. In this case you can re-run configure
# with the verbosity flag -v3 to see the error messages.
# If the header file does exist, it may contain errors that are caught by the C
# compiler at the preprocessing stage. In this case you can re-run configure
# with the verbosity flag -v3 to see the error messages.

# FIXME Need to create 'cabal.project.local' file instead I think.
# https://github.com/haskell/cabal/issues/2997
# Alternatively, can set extra-include-dir in our cabal config file?

# Consider using C_INCLUDE_PATH ?
# https://github.com/haskell/cabal/issues/2705#issue-93071062

# FIXME Need to change ghcup prefix.
# FIXME Consider just adjusting the cabal global store.
# https://cabal.readthedocs.io/en/latest/nix-local-build.html
# configurable via global 'store-dir' option

main() {
    # """
    # Install Pandoc.
    # @note Updated 2023-01-25.
    #
    # @seealso
    # - https://hackage.haskell.org/package/pandoc
    # - https://hackage.haskell.org/package/pandoc-cli
    # - https://github.com/jgm/pandoc/blob/main/CONTRIBUTING.md
    # - https://github.com/jgm/pandoc/blob/main/INSTALL.md
    # - https://cabal.readthedocs.io/
    # - https://cabal.readthedocs.io/en/latest/nix-local-build-overview.html
    # - https://cabal.readthedocs.io/en/stable/cabal-project.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/pandoc.rb
    # """
    local app build_deps dict
    koopa_assert_is_not_aarch64
    build_deps=('git' 'pkg-config')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app 'zlib'
    declare -A app=(
        ['cabal']="$(koopa_locate_cabal)"
        ['ghcup']="$(koopa_locate_ghcup)"
    )
    [[ -x "${app['cabal']}" ]] || return 1
    [[ -x "${app['ghcup']}" ]] || return 1
    declare -A dict=(
        ['ghc_version']='9.4.4'
        ['jobs']="$(koopa_cpu_count)"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
    case "${dict['version']}" in
        '3.0')
            dict['cli_version']='0.1'
            ;;
    esac
    koopa_assert_is_dir "${dict['zlib']}"
    dict['cabal_dir']="$(koopa_init_dir "${dict['prefix']}/libexec/cabal")"
    export CABAL_DIR="${dict['cabal_dir']}"
    dict['ghc_prefix']="$(koopa_init_dir "ghc-${dict['ghc_version']}")"
    "${app['ghcup']}" install \
        'ghc' "${dict['ghc_version']}" \
            --isolate "${dict['ghc_prefix']}"
    koopa_assert_is_dir "${dict['ghc_prefix']}/bin"
    koopa_add_to_path_start "${dict['ghc_prefix']}/bin"
    koopa_init_dir "${dict['prefix']}/bin"
    koopa_print_env
    "${app['cabal']}" v2-update
    "${app['cabal']}" v2-configure \
        --extra-include-dirs="${dict['zlib']}/include" \
        --extra-lib-dirs="${dict['zlib']}/lib"
    "${app['cabal']}" v2-install \
        --install-method='copy' \
        --installdir="${dict['prefix']}/bin" \
        --jobs="${dict['jobs']}" \
        --verbose \
        "pandoc-${dict['version']}" \
        "pandoc-cli-${dict['cli_version']}"
    return 0
}
