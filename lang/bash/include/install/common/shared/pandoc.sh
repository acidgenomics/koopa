#!/usr/bin/env bash

main() {
    # """
    # Install Pandoc.
    # @note Updated 2024-05-13.
    #
    # Note that 'pandoc-lua-engine' is required for R pkgdown.
    #
    # @seealso
    # - https://pandoc.org/releases.html
    # - https://github.com/jgm/pandoc/blob/main/CONTRIBUTING.md
    # - https://github.com/jgm/pandoc/blob/main/INSTALL.md
    # - https://hackage.haskell.org/package/pandoc
    # - https://hackage.haskell.org/package/pandoc-cli
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/pandoc.rb
    # - Regarding data file embedding:
    #   - https://github.com/jgm/pandoc/issues/8560
    #   - https://github.com/Homebrew/homebrew-core/pull/120967
    # """
    koopa_install_haskell_package \
        --dependency='zlib' \
        --extra-package='pandoc-cli' \
        --extra-package='pandoc-lua-engine' \
        --extra-package='pandoc-server' \
        --ghc-version='9.6.5'
    return 0
}
