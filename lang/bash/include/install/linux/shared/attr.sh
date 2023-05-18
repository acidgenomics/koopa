#!/usr/bin/env bash

main() {
    # """
    # @seealso
    # - https://savannah.nongnu.org/projects/attr
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/attr.rb
    # """
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='attr' \
       -D '--disable-debug' \
       -D '--disable-dependency-tracking' \
       -D '--disable-silent-rules'
}
