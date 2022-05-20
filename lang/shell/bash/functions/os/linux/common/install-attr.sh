#!/usr/bin/env bash

koopa_linux_install_attr() {
    # """
    # @seealso
    # - https://savannah.nongnu.org/projects/attr
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/attr.rb
    # """
    koopa_install_app \
        --installer='gnu-app' \
        --name='attr' \
        --platform='linux' \
       -D '--disable-debug' \
       -D '--disable-dependency-tracking' \
       -D '--disable-silent-rules' \
        "$@"
}
